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
import FirebaseDatabase

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    var sceneLocationView = SceneLocationView()
    let locationManager = CLLocationManager()

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

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
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
