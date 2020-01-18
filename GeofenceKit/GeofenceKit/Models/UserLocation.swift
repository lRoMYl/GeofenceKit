// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation
import CoreLocation

public struct UserLocation {
    public let latitude: Double?
    public let longitude: Double?
    public let wifiSsid: String?
    
    public let coordinate: CLLocationCoordinate2D?
    
    public init(latitude: Double?, longitude: Double?, wifiSsid: String?) {
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
    public static func == (lhs: UserLocation, rhs: UserLocation) -> Bool {
        return lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude &&
            lhs.wifiSsid == rhs.wifiSsid
    }
}
