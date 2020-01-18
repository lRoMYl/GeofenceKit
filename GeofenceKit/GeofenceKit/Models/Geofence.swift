// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation
import CoreLocation

struct Geofence {
    let identifier: String
    let latitude: Double
    let longitude: Double
    let radius: Double
    let wifiSsid: String
    
    let coordinate: CLLocationCoordinate2D
    let region: CLCircularRegion
    
    init(
        identifier: String,
        latitude: Double,
        longitude: Double,
        radius: Double,
        wifiSsid: String) {
        self.identifier = identifier
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.wifiSsid = wifiSsid
        
        coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        region = CLCircularRegion(
            center: coordinate,
            radius: radius,
            identifier: identifier)
    }
}

extension Geofence: Equatable {
    static func ==(lhs: Geofence, rhs: Geofence) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
