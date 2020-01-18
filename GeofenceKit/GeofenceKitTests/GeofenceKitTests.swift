// Copyright © 2020 Carousell. All rights reserved.
// 

import XCTest
@testable import GeofenceKit

class GeofenceKitTests: XCTestCase {
    
    class MockUserLocationProvider: UserLocationProviderOverridable {
        var delegate: UserLocationProviderDelegate?
        
        var location: UserLocation? = UserLocation(
            latitude: 3.11, longitude: 103.10, wifiSsid: "test-wifi")
        
        func startMonitoring() {
            delegate?.userLocationProvider(self, didReceive: location!)
        }
        
        func stopMonitoring() { }
        
        func overrideUserLocation(_ userLocation: UserLocation?) {
            self.location = userLocation
        }
    }

    var geofencesInVicinity = [Geofence]()
    var isAccessDenied = false
    var isAccessRestricted = false
    
    override func setUp() {
    }

    override func tearDown() {
        geofencesInVicinity.removeAll()
        isAccessDenied = false
        isAccessRestricted = false
    }

    func testDefaultPolicy() {
        let policy = DefaultPolicy()
        
        let geofenceCoordinateInRegion = Geofence(
            identifier: "test-geofence-identifier",
            latitude: 3.11, longitude: 103.10, radius: 500, wifiSsid: "test")
        
        if let userLocation = MockUserLocationProvider().location {
            XCTAssertTrue(policy.isInVicity(
                geofence: geofenceCoordinateInRegion,
                at: userLocation))
        } else {
            XCTFail("Mock user location shouldn't be nil")
        }
        
    }
    
    func testIsInVicinityCoordinateScenario() {
        let expectation = XCTestExpectation(description: "Wait for geofence result")
        
        let geofenceKit = GeofenceKit(
            policy: DefaultPolicy(), userLocationProvider: MockUserLocationProvider())
        let geofenceCoordinateInRegion = Geofence(
            identifier: "test-geofence-identifier",
            latitude: 3.11, longitude: 103.10, radius: 500, wifiSsid: "test")
        let geofenceWifiSsidNotMatch = Geofence(
            identifier: "test-geofence-identifier",
            latitude: 3.12, longitude: 103.11, radius: 500, wifiSsid: "test")
        
        geofenceKit.delegate = self
        
        geofenceKit.add(geofence: geofenceCoordinateInRegion)
        geofenceKit.add(geofence: geofenceWifiSsidNotMatch)
        
        geofenceKit.startMontoring()
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 3) {
            XCTAssertTrue(self.geofencesInVicinity.count == 1)
            XCTAssertTrue(self.geofencesInVicinity.first == geofenceCoordinateInRegion)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testIsInVicinityWifiSsidScenarios() {
        let expectation = XCTestExpectation(description: "Wait for geofence result")
        
        let geofenceKit = GeofenceKit(
            policy: DefaultPolicy(), userLocationProvider: MockUserLocationProvider())
        let geofenceCoordinateNotInRegion = Geofence(
            identifier: "test-geofence-identifier",
            latitude: 3.12, longitude: 103.11, radius: 500, wifiSsid: "test")
        let geofenceWifiSsidMatch = Geofence(
            identifier: "test-geofence-identifier",
            latitude: 3.11, longitude: 103.10, radius: 500, wifiSsid: "test-wifi")
        
        geofenceKit.delegate = self
        
        geofenceKit.add(geofence: geofenceCoordinateNotInRegion)
        geofenceKit.add(geofence: geofenceWifiSsidMatch)
        
        geofenceKit.startMontoring()
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 3) {
            XCTAssertTrue(self.geofencesInVicinity.count == 1)
            XCTAssertTrue(self.geofencesInVicinity.first == geofenceWifiSsidMatch)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testIsInVicinityAllScenarios() {
        let expectation = XCTestExpectation(description: "Wait for geofence result")
        
        let geofenceKit = GeofenceKit(
            policy: DefaultPolicy(), userLocationProvider: MockUserLocationProvider())
        let geofenceCoordinateInRegion = Geofence(
            identifier: "test-geofence-identifier",
            latitude: 3.11, longitude: 103.10, radius: 500, wifiSsid: "test")
        let geofenceWifiSsidMatch = Geofence(
            identifier: "test-geofence-identifier",
            latitude: 3.11, longitude: 103.10, radius: 500, wifiSsid: "test-wifi")
        
        geofenceKit.delegate = self
        
        geofenceKit.add(geofence: geofenceCoordinateInRegion)
        geofenceKit.add(geofence: geofenceWifiSsidMatch)
        
        geofenceKit.startMontoring()
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 3) {
            XCTAssertTrue(self.geofencesInVicinity.count == 2)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}

extension GeofenceKitTests: GeofenceKitDelegate {
    func geofenceKit(_ geofenceKit: GeofenceKit, didReceiveUpdate geofences: [Geofence]) {
        // Delegate is called multiple times within interval, clear the results
        geofencesInVicinity.removeAll()
        geofencesInVicinity.append(contentsOf: geofences)
    }
    
    func geofenceKitAccessDenied(_ geofenceKit: GeofenceKit) {
        isAccessDenied = true
    }
    
    func geofenceKitAccessRestricted(_ geofenceKit: GeofenceKit) {
        isAccessRestricted = true
    }
}
