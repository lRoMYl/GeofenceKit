// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation
import CoreLocation

public struct Geofence {
    public let identifier: String
    public let latitude: Double
    public let longitude: Double
    public let radius: Double
    public let wifiSsid: String
    
    public let coordinate: CLLocationCoordinate2D
    public let region: CLCircularRegion
    
    public init(
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
    public static func ==(lhs: Geofence, rhs: Geofence) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
