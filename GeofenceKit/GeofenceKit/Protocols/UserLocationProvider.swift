// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation

protocol UserLocationProvider {
    var location: UserLocation { get }
    
    func startMonitoring()
    func stopMonitoring()
}
