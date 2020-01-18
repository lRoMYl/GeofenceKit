// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation
import CoreLocation

struct UserLocation {
    let latitude: Double?
    let longitude: Double?
    let wifiSsid: String?
    
    let coordinate: CLLocationCoordinate2D?
    
    init(latitude: Double?, longitude: Double?, wifiSsid: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.wifiSsid = wifiSsid
        
        if let latitude = latitude, let longitude = longitude {
            coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        } else {
            coordinate = nil
        }
    }
}

extension UserLocation: Equatable {
    static func == (lhs: UserLocation, rhs: UserLocation) -> Bool {
        return lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude &&
            lhs.wifiSsid == rhs.wifiSsid
    }
}
