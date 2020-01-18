// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation

struct Geofence {
    let identifier: String
    let latitude: Double
    let longitude: Double
    let radius: Double
    let wifiSsid: String
}

extension Geofence: Equatable {
    static func ==(lhs: Geofence, rhs: Geofence) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
