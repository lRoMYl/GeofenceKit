// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation
import CoreLocation

public extension CLAuthorizationStatus {
    var isAccessNotDetermined: Bool {
        switch self {
        case .notDetermined: return true
        default: return false
        }
    }
    
    var isAccessDenied: Bool {
        switch self {
        case .notDetermined: return false
        case .denied: return true
        default: return false
        }
    }
    
    var isAccessRestricted: Bool {
        switch self {
        case .notDetermined: return false
        case .restricted: return true
        default: return false
        }
    }
}
