// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation
import CoreLocation

public protocol GeofenceKitDelegate: class {
    func geofenceKit(
        _ geofenceKit: GeofenceKit, didReceiveUpdate geofences: [Geofence])
    func geofenceKitAccessDenied(_ geofenceKit: GeofenceKit)
    func geofenceKitAccessRestricted(_ geofenceKit: GeofenceKit)
}

public final class GeofenceKit {
    public let policy: Policy
    public private(set) var userLocationProvider: UserLocationProviderOverridable
    
    public weak var delegate: GeofenceKitDelegate?
    
    // Internal Props
    private var geofences = [Geofence]()
    private var timer: Timer?
    
    public init(policy: Policy, userLocationProvider: UserLocationProviderOverridable) {
        self.policy = policy
        self.userLocationProvider = userLocationProvider
        self.userLocationProvider.delegate = self
    }
}

// MARK: - Mutation
extension GeofenceKit {
    public func add(geofence: Geofence) {
        geofences.append(geofence)
    }
    
    public func remove(geofence: Geofence) {
        if let idx = geofences.firstIndex(of: geofence) {
            geofences.remove(at: idx)
        }
    }
    
    public func removeAll() {
        geofences.removeAll()
    }
}

// MARK: - Monitoring
extension GeofenceKit {
    public func startMontoring() {
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
    
    public func stopMonitoring() {
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

// MARK: - UserLocationProviderDelegate
extension GeofenceKit: UserLocationProviderDelegate {
    // Do nothing for now, doesn't need to be updated that frequently with such
    // short interval update
    public func userLocationProvider(
        _ provider: UserLocationProvider, didReceive location: UserLocation) { }
    
    public func userLocationProviderAccessDenied(_ provider: UserLocationProvider) {
        delegate?.geofenceKitAccessDenied(self)
    }
    
    public func userLocationProviderAccessRestricted(_ provider: UserLocationProvider) {
        delegate?.geofenceKitAccessRestricted(self)
    }
}
