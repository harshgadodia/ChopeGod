//
//  AppDelegate.swift
//  Chope God
//
//  Created by Harsh Gadodia on 27/1/18.
//  Copyright © 2018 Harsh. All rights reserved.
//

import Foundation

class SceneViewController: ARSceneViewController {
  
  override func createScene() -> SCNScene {
    let scene = super.createScene()
    // Add anything else you want to the scene
    return scene
  }
  
  override func setupTrackables() {
    let imagePath = Bundle.main.path(forResource: "pocky", ofType: "jpg")!
    let image = UIImage(named: imagePath)!
    addTrackable(imagePath, width: image.size.width, height: image.size.height)
  }
}
