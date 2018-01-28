//
//  Data.swift
//  Chope God
//
//  Created by Kar Rui Lau on 28/1/18.
//  Copyright © 2018 Harsh. All rights reserved.
//

import UIKit

class Data: NSObject {
    let lat: String
    let long: String
    let alt: String
    let name: String
    
    init(lat: String, long: String, alt: String, name: String) {
        self.lat = lat
        self.long = long
        self.alt = alt
        self.name = name
    }
}
