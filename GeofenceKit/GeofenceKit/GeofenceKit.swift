// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation
import CoreLocation

protocol GeofenceKitDelegate: class {
    func geofenceKit(
        _ geofenceKit: GeofenceKit, didReceiveUpdate geofences: [Geofence])
    func geofenceKitAccessDenied(_ geofenceKit: GeofenceKit)
    func geofenceKitAccessRestricted(_ geofenceKit: GeofenceKit)
}

class GeofenceKit {
    let policy: Policy
    let userLocationProvider: UserLocationProvider
    
    weak var delegate: GeofenceKitDelegate?
    
    // Internal Props
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
                guard
                    let sself = self,
                    let location = sself.userLocationProvider.location
                else { return }
                
                let results = sself.isInVicinity(
                    geofences: sself.geofences,
                    at: location)
                sself.delegate?.geofenceKit(sself, didReceiveUpdate: results)
        })
        timer?.fire()
        
        userLocationProvider.startMonitoring()
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

extension GeofenceKit: UserLocationProviderDelegate {
    // Do nothing for now, doesn't need to be updated that frequently with such
    // short interval update
    func userLocationProvider(
        _ provider: UserLocationProvider, didReceive location: UserLocation) { }
    
    func userLocationProviderAccessDenied(_ provider: UserLocationProvider) {
        delegate?.geofenceKitAccessDenied(self)
    }
    
    func userLocationProviderAccessRestricted(_ provider: UserLocationProvider) {
        delegate?.geofenceKitAccessRestricted(self)
    }
}
