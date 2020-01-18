// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation
import CoreLocation

class GeofenceKit {
    let policy: Policy
    let userLocationProvider: UserLocationProvider
    
    private var geofences = [Geofence]()
    private var timer: Timer?
    
    init(policy: Policy, userLocationProvider: UserLocationProvider) {
        self.policy = policy
        self.userLocationProvider = userLocationProvider
    }
}

// MARK: - Mutation
extension GeofenceKit {
    func add(geofence: Geofence) {
        geofences.append(geofence)
    }
    
    func remove(geofence: Geofence) {
        if let idx = geofences.firstIndex(of: geofence) {
            geofences.remove(at: idx)
        }
    }
    
    func removeAll() {
        geofences.removeAll()
    }
}

// MARK: - Monitoring
extension GeofenceKit {
    func startMontoring() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(
            withTimeInterval: policy.interval,
            repeats: true, block: { [weak self] _ in
                guard let sself = self else { return }
                
                sself.isInVicinity(
                    geofences: sself.geofences,
                    at: sself.userLocationProvider.location)
        })
        timer?.fire()
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        
        userLocationProvider.stopMonitoring()
    }
}

// MARK: - Internal
extension GeofenceKit {
    private func isInVicinity(
        geofences: [Geofence],
        at userLocation: UserLocation) -> [Geofence] {
        var results = [Geofence]()
        
        geofences.forEach {
            if policy.isInVicity(geofence: $0, at: userLocation) {
                results.append($0)
            }
        }
        
        return results
    }
}
