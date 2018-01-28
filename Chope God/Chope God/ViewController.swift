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
    
    var dataArray = [Data]()

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addNewObjectButton: UIButton!
    
    @IBAction func addNewObjectAction(_ sender: Any) {
        locationManager.startUpdatingLocation()
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Chope Your Space!", message: "Enter Your Name", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Your name here!"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { [weak alert] (_) in
            alert?.dismiss(animated: true, completion: {
            })
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField?.text ?? "nothing entered")")
            //Add name and location to Firebase!
            self.addNode(name: textField!.text!)
        }))
        
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIButton(frame: CGRect(x: sceneLocationView.bounds.midX, y: 200, width: 100, height: 50))
        button.backgroundColor = .green
        button.setTitle("+", for: .normal)
        button.addTarget(self, action: #selector(addNewObjectAction), for: .touchUpInside)
        
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
        retrieveData()
        sceneLocationView.run()
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
        sceneLocationView.run()
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
    
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        if anchor is ARPlaneAnchor {
//            let planeAnchor = anchor as! ARPlaneAnchor
//            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x) , height: CGFloat(planeAnchor.extent.z))
//
//            let planeNode = SCNNode()
//            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
//            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
//
//            let gridMaterial = SCNMaterial()
//            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
//
//            plane.materials = [gridMaterial]
//            planeNode.geometry = plane
//
//            //Add child node to plane
//            node.addChildNode(planeNode)
//        } else {
//            return
//        }
//    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            let touchLocation = touch.location(in: sceneView)
//
//            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
//
//            if let hitResult = results.first {
//
//            }
//        }
//    }
    
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
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
        }
        
        print("Lat: \(location.coordinate.latitude) || Long: \(location.coordinate.longitude) || Altitude: \(location.altitude)")
    }
    
    //MARK: - Add to Firebase
    func addNode(name: String) {
        if let currentLocation = sceneLocationView.currentLocation() {
            let location = CLLocation(coordinate: currentLocation.coordinate, altitude: currentLocation.altitude - 0.5)
            addToFirebase(location: location, name: name)
            let pinLocationNode = LocationAnnotationNode(location: location, image: #imageLiteral(resourceName: "pin"))
            pinLocationNode.scaleRelativeToDistance = true
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
            view.bringSubview(toFront: sceneLocationView)
        }
    }
    
    func addToFirebase(location: CLLocation, name: String) {
        let locationsDB = Database.database().reference().child("locations")
        let locationsDict = ["lat" : String(location.coordinate.latitude),
                             "long" : String(location.coordinate.longitude),
                             "alt" : String(location.altitude),
                             "name" : name]
        locationsDB.childByAutoId().setValue(locationsDict) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            } else {
                print("location saved successfully!")
            }
        }
    }
    
    //MARK: - Retrieve from Firebase
    func retrieveData() {
        print("Retrieving data!")
        let dataDB = Database.database().reference().child("locations")
        dataDB.observe(.childAdded, with: { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            let lat = snapshotValue["lat"]!
            let long = snapshotValue["long"]!
            let alt = snapshotValue["alt"]!
            let name = snapshotValue["name"]!
            
            let data = Data(lat: lat, long: long, alt: alt, name: name)
            self.dataArray.append(data)
        })
        displayNodes(dataArray: self.dataArray)
    }
    
    func displayNodes(dataArray: [Data]) {
        for data in dataArray {
            let coordinates = CLLocationCoordinate2D(latitude: Double(data.lat)!, longitude: Double(data.long)!)
            
            let location = CLLocation(coordinate: coordinates, altitude: Double(data.alt)!)
            let pinLocationNode = LocationAnnotationNode(location: location, image: #imageLiteral(resourceName: "pin"))
            pinLocationNode.scaleRelativeToDistance = true
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
            
            print("loaded lat: \(data.lat), long: \(data.long), alt: \(data.alt)")
        }
    }
}
