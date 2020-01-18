// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation
import CoreLocation
import SystemConfiguration.CaptiveNetwork

class DefaultUserLocationProvider: NSObject, UserLocationProvider {
    weak var delegate: UserLocationProviderDelegate?
    var location: UserLocation?
    
    // Internal props
    private var locationManager = CLLocationManager()
    private var lastKnownLocation: CLLocation?
    private var lastKnownWifi: String?
    private var timer: Timer?
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
    }
    
    func startMonitoring() {
        if CLLocationManager.authorizationStatus().isAccessNotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus().isAccessDenied {
            delegate?.userLocationProviderAccessDenied(self)
        } else if CLLocationManager.authorizationStatus().isAccessRestricted {
            delegate?.userLocationProviderAccessRestricted(self)
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopMonitoring() {
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
    }
    
    private func startUpdating() {
        locationManager.startUpdatingLocation()
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.lastKnownWifi = self?.getWifiSsid()
            self?.updateUserLocationAndNotifyIfNeeded()
        })
    }
    
    private func updateUserLocationAndNotifyIfNeeded() {
        let newLocation = UserLocation(
            latitude: lastKnownLocation?.coordinate.latitude,
            longitude: lastKnownLocation?.coordinate.longitude,
            wifiSsid: lastKnownWifi)
        
        if newLocation != location {
            location = newLocation
            delegate?.userLocationProvider(self, didReceive: newLocation)
        }
    }
}

// MARK: - Getters
extension DefaultUserLocationProvider {
    private func getWifiSsid() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
}

extension DefaultUserLocationProvider: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            lastKnownLocation = location
            updateUserLocationAndNotifyIfNeeded()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status.isAccessRestricted {
            delegate?.userLocationProviderAccessRestricted(self)
        } else if status.isAccessDenied {
            delegate?.userLocationProviderAccessDenied(self)
        } else {
            locationManager.startUpdatingLocation()
        }
    }
}

private extension CLAuthorizationStatus {
    var isAccessNotDetermined: Bool {
        switch self {
        case .notDetermined: return true
        default: return false
        }
    }
    
    var isAccessDenied: Bool {
        switch self {
        case .denied: return true
        default: return false
        }
    }
    
    var isAccessRestricted: Bool {
        switch self {
        case .restricted: return true
        default: return false
        }
    }
}
