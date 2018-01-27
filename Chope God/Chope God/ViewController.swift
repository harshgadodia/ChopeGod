//
//  ViewController.swift
//  Chope God
//
//  Created by Harsh Gadodia on 27/1/18.
//  Copyright © 2018 Harsh. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    enum ARCoffeeSessionState: String, CustomStringConvertible {
        case initialized = "initialized", ready = "ready", temporarilyUnavailable = "temporarily unavailable", failed = "failed"
        
        var description: String {
            switch self {
            case .initialized:
                return "👀 Look for a plane to place your coffee"
            case .ready:
                return "☕️ Click any plane to place your coffee!"
            case .temporarilyUnavailable:
                return "😱 Adjusting caffeine levels. Please wait"
            case .failed:
                return "⛔️ Caffeine crisis! Please restart App."
            }
        }
    }

    var currentCaffeineStatus = ARCoffeeSessionState.initialized {
        didSet {
            DispatchQueue.main.async { self.statusLabel.text = self.currentCaffeineStatus.description }
            if currentCaffeineStatus == .failed {
                cleanupARSession()
            }
        }
    }
    
    func cleanupARSession() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            node.removeFromParentNode()
        }
    }


    @IBOutlet var sceneView: ARSCNView!
    
    var antNode:SCNNode!
    
    func initializeAntNode() {
        let antScene = SCNScene(named: "ant.dae")!
        self.antNode = antScene.rootNode.childNode(withName: "ant", recursively: true)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //show coordinate axis
        sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //smooths edges in rendered scenes
        sceneView.antialiasingMode = .multisampling4X
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Add feature points
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        let modelScene = SCNScene(named:
            "art.scnassets/ant.scn")!
        
//        nodeModel =  modelScene.rootNode.childNode(
//            withName: nodeName, recursively: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            print("Unable to identify touches on any plane. Ignoring interaction...")
            return
        }
        if currentCaffeineStatus != .ready {
            print("Unable to place objects when the planes are not ready...")
            return
        }
        
        let touchPoint = touch.location(in: sceneView)
        if let plane = virtualPlaneProperlySet(touchPoint: touchPoint) {
            print("Plane touched: \(plane)")
            addCoffeeToPlane(plane: plane, atPoint: touchPoint)
        }
        
//        let location = touches.first!.location(in: sceneView)
//        var hitTestOptions = [SCNHitTestOption: Any]()
//        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
//        let hitResults: [SCNHitTestResult]  =
//            sceneView.hitTest(location, options: hitTestOptions)
//        if let hit = hitResults.first {
//            if let node = getParent(hit.node) {
//                node.removeFromParentNode()
//                return
//            }
//        }
//        let hitResultsFeaturePoints: [ARHitTestResult] =
//            sceneView.hitTest(location, types: .featurePoint)
//        if let hit = hitResultsFeaturePoints.first {
//            sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
//        }
    }
    
    func virtualPlaneProperlySet(touchPoint: CGPoint) -> VirtualPlane? {
        let hits = sceneView.hitTest(touchPoint, types: .existingPlaneUsingExtent)
        if hits.count > 0, let firstHit = hits.first, let identifier = firstHit.anchor?.identifier, let plane = planes[identifier] {
            self.selectedPlane = plane
            return plane
        }
        return nil
    }
    
//    func getParent(_ nodeFound: SCNNode?) -> SCNNode? {
//        if let node = nodeFound {
//            if node.name == nodeName {
//                return node
//            } else if let parent = node.parent {
//                return getParent(parent)
//            }
//        }
//        return nil
//    }

    func addCoffeeToPlane(plane: VirtualPlane, atPoint point: CGPoint) {
        let hits = sceneView.hitTest(point, types: .existingPlaneUsingExtent)
        if hits.count > 0, let firstHit = hits.first {
            if let anotherAntYesPlease = antNode?.clone() {
                anotherAntYesPlease.position = SCNVector3Make(firstHit.worldTransform.columns.3.x, firstHit.worldTransform.columns.3.y, firstHit.worldTransform.columns.3.z)
                sceneView.scene.rootNode.addChildNode(anotherAntYesPlease)
            }
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
//    // Override to create and configure nodes for anchors added to the view's session.
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        let node = SCNNode()
//
//        return node
//    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
//        if !anchor.isKind(of: ARPlaneAnchor.self) {
//            DispatchQueue.main.async {
//                let modelClone = self.nodeModel.clone()
//                modelClone.position = SCNVector3Zero
//                // Add model as a child of the node
//                node.addChildNode(modelClone)
//            }
//        }
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x) , height: CGFloat(planeAnchor.extent.z))

            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)

            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")

            plane.materials = [gridMaterial]
            planeNode.geometry = plane

            //Add child node to plane
            node.addChildNode(planeNode)
        } else {
            return
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
