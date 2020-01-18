// Copyright © 2020 Carousell. All rights reserved.
// 

import XCTest
@testable import Demo
import GeofenceKit

class DemoTests: XCTestCase {
    
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
    
    class MockDeniedUserLocationProvider: UserLocationProviderOverridable {
        var delegate: UserLocationProviderDelegate?
        
        var location: UserLocation? = UserLocation(
            latitude: 3.11, longitude: 103.10, wifiSsid: "test-wifi")
        
        func startMonitoring() {
            delegate?.userLocationProviderAccessDenied(self)
        }
        
        func stopMonitoring() { }
        
        func overrideUserLocation(_ userLocation: UserLocation?) {
            self.location = userLocation
        }
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitialState() {
        let expectation = XCTestExpectation(description: "Wait for geofence result")
        
        let homeView = HomeView(
            viewModel: HomeViewModel(
                policy: DefaultPolicy(),
                userLocationProvider: MockUserLocationProvider(),
                overrideUserLocationProvider: MockUserLocationProvider()))
        
        homeView.viewModel.onTapMonitor()
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 3) {
            XCTAssertTrue(
                homeView.viewModel.title == "IN REGION",
                """
                viewModel.overrideUserLocation is not true yet, so user location
                should still be (0, 0) making the result to be IN REGION
                """)
            
            homeView.viewModel.onTapCopyUserLocation()
            
            XCTAssertTrue(
                homeView.viewModel.wifiSsid == "",
                "Expecting `` from default value but got `\(homeView.viewModel.wifiSsid)`")
            XCTAssertTrue(homeView.viewModel.latitude == 0.0,
                "Expecting `0.0` from default value but got `\(homeView.viewModel.latitude)`")
            XCTAssertTrue(homeView.viewModel.longitude == 0.0,
                "Expecting `0.0` from default value but got `\(homeView.viewModel.longitude)`")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testDefaultUserLocationState() {
        let expectation = XCTestExpectation(description: "Wait for geofence result")
        
        let homeView = HomeView(
            viewModel: HomeViewModel(
                policy: DefaultPolicy(),
                userLocationProvider: MockUserLocationProvider(),
                overrideUserLocationProvider: MockUserLocationProvider()))
        
        homeView.viewModel.userLocationOverride = false
        homeView.viewModel.onTapMonitor()
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 3) {
            XCTAssertTrue(
                homeView.viewModel.title == "OUTSIDE REGION",
                """
                viewModel.overrideUserLocation is false, so user location
                should still be (3.11, 103.10) making the result to be
                OUTSIDE REGION
                """)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testOverrideUserLocationState() {
        let expectation = XCTestExpectation(description: "Wait for geofence result")
        
        let homeView = HomeView(
            viewModel: HomeViewModel(
                policy: DefaultPolicy(),
                userLocationProvider: MockUserLocationProvider(),
                overrideUserLocationProvider: MockUserLocationProvider()))
        
        homeView.viewModel.latitude = 1.11
        homeView.viewModel.longitude = 100.11
        homeView.viewModel.userLatitude = 1.11
        homeView.viewModel.userLongitude = 100.11
        homeView.viewModel.onTapMonitor()
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 3) {
            XCTAssertTrue(
                homeView.viewModel.title == "IN REGION",
                """
                geofence coordinate and user coordinate is modified, user location
                should be (1.11, 100.11) making the result to be INSIDE REGION
                but instead got `\(homeView.viewModel.title)`
                """)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCopyUserLocationWithUserLocationProvider() {
        let expectation = XCTestExpectation(description: "Wait for geofence result")
        
        let homeView = HomeView(
            viewModel: HomeViewModel(
                policy: DefaultPolicy(),
                userLocationProvider: MockUserLocationProvider(),
                overrideUserLocationProvider: MockUserLocationProvider()))
        
        homeView.viewModel.userLocationOverride = false
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 3) {
            homeView.viewModel.onTapCopyUserLocation()
            
            XCTAssertTrue(
                homeView.viewModel.wifiSsid == "test-wifi",
                "Expecting `test-wifi` but got `\(homeView.viewModel.wifiSsid)`")
            XCTAssertTrue(homeView.viewModel.latitude == 3.11,
                "Expecting `3.11` but got `\(homeView.viewModel.latitude)`")
            XCTAssertTrue(homeView.viewModel.longitude == 103.10,
                "Expecting `103.10` but got `\(homeView.viewModel.longitude)`")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAccessDeniedState() {
        let homeView = HomeView(
            viewModel: HomeViewModel(
                policy: DefaultPolicy(),
                userLocationProvider: MockDeniedUserLocationProvider(),
                overrideUserLocationProvider: MockDeniedUserLocationProvider()))
        
        homeView.viewModel.userLocationOverride = false
        
        XCTAssertTrue(homeView.viewModel.isAccessDenied, "Access should be denied")
    }
}
