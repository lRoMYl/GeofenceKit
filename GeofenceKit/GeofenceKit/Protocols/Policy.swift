// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation
import CoreLocation

public protocol Policy {
    var interval: TimeInterval { get } 
    
    func isInVicity(
        geofence: Geofence,
        at userLocation: UserLocation) -> Bool
}
