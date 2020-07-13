//
//  WeatherLocation.swift
//  WeatherPic
//
//  Created by Romain Francois on 05/07/2020.
//  Copyright © 2020 Romain Francois. All rights reserved.
//

import Foundation

class WeatherLocation: Codable {
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
