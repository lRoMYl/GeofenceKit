// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation

public protocol UserLocationProviderDelegate: class {
    func userLocationProvider(
        _ provider: UserLocationProvider, didReceive location: UserLocation)
    func userLocationProviderAccessDenied(_ provider: UserLocationProvider)
    func userLocationProviderAccessRestricted(_ provider: UserLocationProvider)
}

public protocol UserLocationProvider {
    var delegate: UserLocationProviderDelegate? { get set }
    var location: UserLocation? { get }
    
    func startMonitoring()
    func stopMonitoring()
}
