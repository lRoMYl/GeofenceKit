// Copyright © 2020 Carousell. All rights reserved.
// 

import Foundation
import Combine
import GeofenceKit

protocol HomeViewModelType {
    var title: String { get }
    
    var wifiSsid: String { get set }
    var latitude: Double { get set }
    var longitude: Double { get set }
    var radius: Double { get set }
    var monitoring: Bool { get }
    
    var userLatitude: Double { get set }
    var userLongitude: Double { get set }
    var overrideUserLocation: Bool { get set }
    
    var validLatitudeRanges: ClosedRange<Double> { get }
    var validLongitudeRanges: ClosedRange<Double> { get }
    var validRadiusRanges: ClosedRange<Double> { get }
    
    func startMonitoring()
    func stopMonitoring()
}

class HomeViewModel: NSObject, ObservableObject, HomeViewModelType {
    private(set) var title = ""
    
    var wifiSsid = "ssid"
    var latitude = 0.0
    var longitude = 0.0
    var radius = 0.0
    private(set) var monitoring = false
    
    var userLatitude = 0.0
    var userLongitude = 0.0
    var overrideUserLocation = false
    
    let validLatitudeRanges = -90.0...90.0
    let validLongitudeRanges = -180.0...180.0
    let validRadiusRanges = 500.0...50000.0
    
    func startMonitoring() {
        
    }
    
    func stopMonitoring() {
        
    }
}
