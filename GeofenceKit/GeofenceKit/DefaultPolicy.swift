// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation

struct DefaultPolicy: Policy {
    let interval: TimeInterval = 1.0
    
    func isInVicity(geofence: Geofence, at userLocation: UserLocation) -> Bool {
        if let coordinate = userLocation.coordinate {
            return geofence.region.contains(coordinate) ||
                geofence.wifiSsid == userLocation.wifiSsid
        } else {
            return geofence.wifiSsid == userLocation.wifiSsid
        }
    }
}
