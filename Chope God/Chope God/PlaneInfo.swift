//
//  PlaneInfo.swift
//  Chope God
//
//  Created by Kar Rui Lau on 27/1/18.
//  Copyright © 2018 Harsh. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class PlaneInfo: NSObject {
    let transform: float4x4
    let center: float3
    let extent: float3
    let imageNumber: Int
    
    init(anchor: ARPlaneAnchor, num: Int) {
        transform = anchor.transform
        center = anchor.center
        extent = anchor.extent
        imageNumber = num
    }
}

// convenience vector-width conversions used above
extension float4 {
    init(_ xyz: float3, _ w: Float) {
        self.init(xyz.x, xyz.y, xyz.z, 1)
    }
    var xyz: float3 {
        return float3(self.x, self.y, self.z)
    }
}
