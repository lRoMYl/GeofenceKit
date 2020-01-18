// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation

public struct DefaultPolicy: Policy {
    public let interval: TimeInterval = 1
    
    public func isInVicity(geofence: Geofence, at userLocation: UserLocation) -> Bool {
        if let coordinate = userLocation.coordinate {
            return geofence.region.contains(coordinate) ||
                geofence.wifiSsid == userLocation.wifiSsid
        } else {
            return geofence.wifiSsid == userLocation.wifiSsid
        }
    }
    
    public init() {}
}
