// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation
import CoreLocation

struct UserLocation {
    let latitude: Double?
    let longitude: Double?
    let wifiSsid: String?
}

// MARK: - Compute Variables
extension UserLocation {
    var coordinate: CLLocationCoordinate2D? {
        guard
            let latitude = latitude,
            let longitude = longitude
        else { return nil }
        
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}
