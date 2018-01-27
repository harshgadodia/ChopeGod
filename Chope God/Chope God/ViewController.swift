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
import ARCL
import CoreLocation
import MapKit
import PopupDialog

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    var sceneLocationView = SceneLocationView()
    let locationManager = CLLocationManager()
    var lastLocation = CLLocation()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Add feature points
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        // Get location data
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            lastLocation = location
        }
        print("locations = \(location.coordinate.latitude) \(location.coordinate.longitude)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
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
    
    // Render the horizontal plane
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)

            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)

            if let hitResult = results.first {
                
                let title = "Chope your seat!"
                let message = "Choose your object to reserve your seat with"
                
                let popup = PopupDialog(title: title, message: message)
                
                // Create buttons
                let buttonOne = CancelButton(title: "Dice") {
                    // Create a new scene
                    let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                    
                    if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                        
                        diceNode.position = SCNVector3(
                            x: hitResult.worldTransform.columns.3.x,
                            y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                            z: hitResult.worldTransform.columns.3.z
                        )
                        
                        self.sceneView.scene.rootNode.addChildNode(diceNode)
                        
                    }
                }
                
                // This button will not the dismiss the dialog
                let buttonTwo = DefaultButton(title: "Starbucks") {
                    // Create a new scene
                    let antScene = SCNScene(named: "art.scnassets/StrBucks.scn")!
                    
                    if let antNode = antScene.rootNode.childNode(withName: "ant", recursively: true) {
                        
                        antNode.position = SCNVector3(
                            x: hitResult.worldTransform.columns.3.x,
                            y: hitResult.worldTransform.columns.3.y + antNode.boundingSphere.radius,
                            z: hitResult.worldTransform.columns.3.z
                        )
                        
                        self.sceneView.scene.rootNode.addChildNode(antNode)
                        
                    }

                }
                
                let buttonThree = DefaultButton(title: "Courage the Cowardly Dog", height: 60) {
                    // Create a new scene
                    let courageScene = SCNScene(named: "art.scnassets/courage_apply.scn")!
                    
                    if let courageNode = courageScene.rootNode.childNode(withName: "courage", recursively: true) {
                        
                        courageNode.position = SCNVector3(
                            x: hitResult.worldTransform.columns.3.x,
                            y: hitResult.worldTransform.columns.3.y + courageNode.boundingSphere.radius,
                            z: hitResult.worldTransform.columns.3.z
                        )
                        
                        self.sceneView.scene.rootNode.addChildNode(courageNode)
                        
                    }
                }
                
                popup.addButtons([buttonOne, buttonTwo, buttonThree])
                
                self.present(popup, animated: true, completion: nil)
                

                
            }
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
    
    // MARK: - Saving plane info
    func makePlane(from planeInfo: PlaneInfo) -> SCNNode { // call this when you place content
        let extent = planeInfo.extent
        let center = float4(planeInfo.center, 1) * planeInfo.transform
        // we're positioning content in world space, so center is now
        // an offset relative to transform
        
        let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = .pi / 2
        planeNode.simdPosition = center.xyz
        
        return planeNode
    }
    
    // load the image chosen using the imageNumber
    func loadImageChosen(from planeInfo: PlaneInfo) {
        
    }
}
