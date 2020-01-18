// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation
import Combine
import GeofenceKit
import CoreLocation

enum HomeViewAlertType {
    case restricted
    case denied
    
    var title: String {
        return "Alert"
    }
    
    var text: String {
        switch self {
        case .denied: return "Location permission is denied, please goto setting page to enable it"
        case .restricted: return "Your device location access is restricted, unable to override usr location"
        }
    }
}

protocol HomeViewModelType {
    // Inputs
    var wifiSsid: String { get set }
    var latitude: Double { get set }
    var longitude: Double { get set }
    var radius: Double { get set }
    var monitoring: Bool { get }
    
    var userLatitude: Double { get set }
    var userLongitude: Double { get set }
    var userLocationOverride: Bool { get set }
    
    var showAlert: Bool { get set }
    var alertType: HomeViewAlertType { get set }
    
    // Outputs
    var title: String { get }
    
    var sectionGeofenceHeader: String { get }
    var wifiSsidTitle: String { get }
    var wifiSsidPlaceholder: String { get }
    var latitudeTitle: String { get }
    var longitudeTitle: String { get }
    var radiusTitle: String { get }
    var monitorButtonTitle: String { get }
    var copyUserLocationButtonTitle: String { get }
    
    var sectionUserHeader: String { get }
    var userOverrideTitle: String { get }
    var userLatitudeTitle: String { get }
    var userLongitudeTitle: String { get }
    
    var minLatitudeText: String { get }
    var maxLatitudeText: String { get }
    var minLongitudeText: String { get }
    var maxLongitudeText: String { get }
    var minRadiusText: String { get }
    var maxRadiusText: String { get }
    
    var validLatitudeRanges: ClosedRange<Double> { get }
    var validLongitudeRanges: ClosedRange<Double> { get }
    var validRadiusRanges: ClosedRange<Double> { get }
    
    var isAccessDenied: Bool { get }
    var isAccessRestricted: Bool { get }
    
    func onTapMonitor()
    func onTapCopyUserLocation()
}

class HomeViewModel: NSObject, ObservableObject, HomeViewModelType {
    let objectWillChange = ObservableObjectPublisher()
    
    // Inputs
    var wifiSsid = "0000-0000-0000-0000"
    var latitude = 0.0 { didSet { objectWillChange.send() } }
    var longitude = 0.0 { didSet { objectWillChange.send() } }
    var radius = 500.0 { didSet { objectWillChange.send() } }
    private(set) var monitoring = false { didSet { objectWillChange.send() } }
    
    var userLatitude = 0.0 {
        didSet {
            objectWillChange.send()
            updateUserLocation()
        }
    }
    var userLongitude = 0.0 {
        didSet {
            objectWillChange.send()
            updateUserLocation()
        }
    }
    var userLocationOverride = true {
        didSet {
            userLocationOverride
                ? stopMonitoringUserLocation()
                : startMonitoringUserLocation()
            objectWillChange.send()
        }
    }
    
    var showAlert = false {
        didSet {
            // Current alert usage to show show location permission error,
            // thus always change back userLocationOverride to true as we
            // couldn't retrieve user location
            if !showAlert {
                userLocationOverride = true
            }
            objectWillChange.send()
        }
    }
    var alertType: HomeViewAlertType = .denied
    
    // Outputs
    private(set) var title = "" { didSet { objectWillChange.send() } }
    
    let sectionGeofenceHeader = "Geofence Config"
    let wifiSsidTitle = "WiFi SSID"
    let wifiSsidPlaceholder = ""
    var latitudeTitle: String {
        return "Latitude: \(String(format: "%.6f", latitude))"
    }
    var longitudeTitle: String {
        return "Longitude: \(String(format: "%.6f", longitude))"
    }
    var radiusTitle: String {
        return "Radius: \(String(format: "%.3f", radius/1000))km"
    }
    var monitorButtonTitle: String {
        return monitoring ? "Stop Monitoring" : "Monitor"
    }
    let copyUserLocationButtonTitle = "Copy User Location"
    
    let sectionUserHeader = "User Location"
    var userOverrideTitle = "Override User Location"
    var userLatitudeTitle: String {
        return "Latitude: \(String(format: "%.6f", userLatitude))"
    }
    var userLongitudeTitle: String {
        return "Longitude: \(String(format: "%.6f", userLongitude))"
    }
    
    lazy private(set) var minLatitudeText = {
        String(format: "%.1f", self.validLatitudeRanges.lowerBound)
    }()
    lazy private(set) var maxLatitudeText = {
       String(format: "%.1f", self.validLatitudeRanges.upperBound)
    }()
    lazy private(set) var minLongitudeText = {
       String(format: "%.1f", self.validLongitudeRanges.lowerBound)
    }()
    lazy private(set) var maxLongitudeText = {
       String(format: "%.1f", self.validLongitudeRanges.upperBound)
    }()
    lazy private(set) var minRadiusText = {
       String(Int(self.validRadiusRanges.lowerBound))
    }()
    lazy private(set) var maxRadiusText = {
        String(Int(self.validRadiusRanges.upperBound))
    }()
    
    let validLatitudeRanges = -90.0...90.0
    let validLongitudeRanges = -180.0...180.0
    let validRadiusRanges = 500.0...50000.0
    
    var isAccessDenied = CLLocationManager.authorizationStatus().isAccessDenied
    var isAccessRestricted = CLLocationManager.authorizationStatus().isAccessRestricted
    
    private var geofenceKit: GeofenceKit
    private var overrideUserLocationProvider: UserLocationProvider
    
    init(
        policy: Policy,
        userLocationProvider: UserLocationProvider,
        overrideUserLocationProvider: UserLocationProvider) {
        geofenceKit = GeofenceKit(policy: policy, userLocationProvider: userLocationProvider)
        self.overrideUserLocationProvider = overrideUserLocationProvider
        super.init()
        geofenceKit.delegate = self
        self.overrideUserLocationProvider.delegate = self
        updateUserLocation()
    }
    
    func onTapMonitor() {
        monitoring ? stopMonitoring() : startMonitoring()
    }
    
    func onTapCopyUserLocation() {
        latitude = userLatitude
        longitude = userLongitude
        updateGeofences()
    }
}

// MARK: - Internal Actions
extension HomeViewModel {
    private func updateGeofences() {
        geofenceKit.removeAll()
        let geofence = Geofence(
            identifier: UUID().uuidString,
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            wifiSsid: wifiSsid)
        geofenceKit.add(geofence: geofence)
    }
    
    private func startMonitoring() {
        monitoring = true
        
        updateGeofences()
        
        geofenceKit.startMontoring()
    }
    
    private func stopMonitoring() {
        monitoring = false
        title = ""
        geofenceKit.stopMonitoring()
    }
    
    private func startMonitoringUserLocation() {
        overrideUserLocationProvider.startMonitoring()
    }
    
    private func stopMonitoringUserLocation() {
        overrideUserLocationProvider.stopMonitoring()
    }
    
    private func updateUserLocation() {
        let userLocation = UserLocation(
            latitude: userLatitude, longitude: userLongitude, wifiSsid: "")
        geofenceKit.setCustomUserLocation(userLocation)
    }
}

extension HomeViewModel: GeofenceKitDelegate {
    func geofenceKit(_ geofenceKit: GeofenceKit, didReceiveUpdate geofences: [Geofence]) {
        title = geofences.count > 0 ? "IN REGION" : "OUTSIDE REGION"
    }
    
    // Geokit access permission error from showing alert doesn't have to show
    // alert atm, as the user experience is quite terrible
    func geofenceKitAccessDenied(_ geofenceKit: GeofenceKit) { }
    func geofenceKitAccessRestricted(_ geofenceKit: GeofenceKit) { }
}

extension HomeViewModel: UserLocationProviderDelegate {
    func userLocationProvider(_ provider: UserLocationProvider, didReceive location: UserLocation) {
        if let latitude = location.latitude, let longtitude = location.longitude {
            userLatitude = latitude
            userLongitude = longtitude
        }
    }
    
    func userLocationProviderAccessDenied(_ provider: UserLocationProvider) {
        showAlert = true
        alertType = .denied
    }
    
    func userLocationProviderAccessRestricted(_ provider: UserLocationProvider) {
        showAlert = true
        alertType = .restricted
    }
}
