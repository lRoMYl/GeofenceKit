// Copyright © 2020 Carousell. All rights reserved.
// 

import XCTest
@testable import Demo
import GeofenceKit

class DemoTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitialState() {
        let expectation = XCTestExpectation(description: "Wait for geofence result")
        
        struct MockUserLocationProvider: UserLocationProvider {
            var delegate: UserLocationProviderDelegate?
            
            var location: UserLocation? = UserLocation(
                latitude: 3.11, longitude: 103.10, wifiSsid: "test-wifi")
            
            func startMonitoring() { }
            
            func stopMonitoring() { }
        }
        
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
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testOverrideUserLocationState() {
        let expectation = XCTestExpectation(description: "Wait for geofence result")
        
        struct MockUserLocationProvider: UserLocationProvider {
            var delegate: UserLocationProviderDelegate?
            
            var location: UserLocation? = UserLocation(
                latitude: 3.11, longitude: 103.10, wifiSsid: "test-wifi")
            
            func startMonitoring() {
                delegate?.userLocationProvider(self, didReceive: location!)
            }
            
            func stopMonitoring() { }
        }
        
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
}
