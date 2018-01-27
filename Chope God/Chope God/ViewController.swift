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
import PopupDialog
import FirebaseDatabase

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    var sceneLocationView = SceneLocationView()
    let locationManager = CLLocationManager()

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addNewObjectButton: UIButton!
    
    @IBAction func addNewObjectAction(_ sender: Any) {
        let title = "Chope your seat!"
        let message = "Choose your object to reserve your seat with"
        
        let popup = PopupDialog(title: title, message: message)
        
        // Create buttons
        let buttonOne = CancelButton(title: "Dice") {
            // Create a new scene
            let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
            
            if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                
                diceNode.position = SCNVector3(
//                    x: hitResult.worldTransform.columns.3.x,
//                    y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
//                    z: hitResult.worldTransform.columns.3.z
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
//                    x: hitResult.worldTransform.columns.3.x,
//                    y: hitResult.worldTransform.columns.3.y + antNode.boundingSphere.radius,
//                    z: hitResult.worldTransform.columns.3.z
                )
                
                self.sceneView.scene.rootNode.addChildNode(antNode)
                
            }
            
        }
        
        let buttonThree = DefaultButton(title: "Courage the Cowardly Dog", height: 60) {
            // Create a new scene
            let courageScene = SCNScene(named: "art.scnassets/courage_apply.scn")!
            
            if let courageNode = courageScene.rootNode.childNode(withName: "courage", recursively: true) {
                
                courageNode.position = SCNVector3(
//                    x: hitResult.worldTransform.columns.3.x,
//                    y: hitResult.worldTransform.columns.3.y + courageNode.boundingSphere.radius,
//                    z: hitResult.worldTransform.columns.3.z
                )
                
                self.sceneView.scene.rootNode.addChildNode(courageNode)
                
            }
        }
        
        popup.addButtons([buttonOne, buttonTwo, buttonThree])
        
        self.present(popup, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.backgroundColor = .green
        button.setTitle("Test Button", for: .normal)
        button.addTarget(self, action: #selector(addNewObjectAction), for: .touchUpInside)
        
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        sceneLocationView.addSubview(button)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        // Set up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Load chopes
        //Currently set to Cinammon Dining Hall
        let pinCoordinate = CLLocationCoordinate2D(latitude: 1.30631563896222, longitude: 103.773329239156)
        let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 23)
        let pinImage = UIImage(named: "pin")!
        let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
        pinLocationNode.scaleRelativeToDistance = true
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
        
        view.addSubview(sceneLocationView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

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

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
       
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
    
    //MARK: - Location Manager Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
//        if location.horizontalAccuracy > 0 {
//            locationManager.stopUpdatingLocation()
//        }
        
        print("Lat: \(location.coordinate.latitude) || Long: \(location.coordinate.longitude) || Altitude: \(location.altitude)")
    }
    
    //MARK: - Add to Firebase
    func addNode() {
        if let currentLocation = sceneLocationView.currentLocation() {
            let location = CLLocation(coordinate: currentLocation.coordinate, altitude: currentLocation.altitude - 0.5)
            addToFirebase(location: location)
            let pinLocationNode = LocationAnnotationNode(location: location, image: #imageLiteral(resourceName: "pin"))
            pinLocationNode.scaleRelativeToDistance = true
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
        }
    }
    
    func addToFirebase(location: CLLocation) {
        let locationsDB = Database.database().reference().child("locations")
        let locationsDict = ["lat" : location.coordinate.latitude,
                             "long" : location.coordinate.longitude,
                             "alt" : location.altitude]
        locationsDB.childByAutoId().setValue(locationsDict) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            } else {
                print("location saved successfully!")
            }
        }
    }
}
