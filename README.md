# GeofenceKit

## Intro
A demo of how to simulate geofence manually without using Apple own built-in support for geofence.

The criteria for a geofence in this demo is as follows
- Region: Latitude, Longitude and radius
- WiFi SSID

A user is considered to be within the geofence if its either in the region or connected to the defined WiFi SSID

## Setup
For the purpose of this demo, the code will be split into GeofenceKit library and a demo app.

As there are no external dependencies used for this demo, you do not have to install any dependency manager or setup

### Simulator
- Open the workspace GeofenceKit.xcworkspace and choose the Demo app to run the demo app

### Device
- Open the workspace GeofenceKit.xcworkspace and choose the Demo app to run the demo app
- Configure the Bundle identifier and provising profile to deploy to your device 

## Known Issues
- WiFi SSID would no longer work very well as of iOS 13, this requires the user to be connected to VPN before the information can be retrieved.
- The keyboard scrolling is a bit wonky but I don't feel the need to import a 3rd party framework to solve the issue for this demo

## Implementation Details
### GeofenceKit Library
This is a standalone library that comes with the data model and location tracker to determine if the given location is within or outside of the defined geofences.

#### GeofenceKit
GeofenceKit is the primary integration interface and can be configured using `Policy` which defines the rules and behaviours and `UserLocationProvider` to receive the location that it needs to monitor the entry of exit from geofences.

The demo app would act as an inteface for the user to customize GeofenceKit parameters to simulate its capabilities

Mutator functions to add or remove geofence for monitoring
```
public func add(geofence: Geofence)
public func remove(geofence: Geofence)
public func removeAll()
```

Monitoring functions which can be started or stopped
```
public func startMontoring()
public func stopMonitoring()
```

GeofenceKitDelegate interface which is used to notify state or data changes
```
public func geofenceKit(
        _ geofenceKit: GeofenceKit, didReceiveUpdate geofences: [Geofence])
public func geofenceKitAccessDenied(_ geofenceKit: GeofenceKit)
public func geofenceKitAccessRestricted(_ geofenceKit: GeofenceKit)
```

#### Policy
Policy is an interface that defines the rules or behaviour in GeofenceKit such as the refresh interval and the rules that constitue a location is inside or outside of the geofence.

Thus it is possible to have a separate definition for interval and geofencing using the same library depending on the acceptance criteria

A default policy is provided for this demo, `DefaultPolicy`

```
var interval: TimeInterval { get } 
func isInVicity(geofence: Geofence, userLocation: UserLocation) -> Bool
```

#### UserLocationProvider
UserLocationProvider is an interface that defines how to retrieve the user location and provides mechanism to decide when to start or stop the monitoring.

A default provider is provided for this demo, `DefaultUserLocationProvider`

```
var location: UserLocation? { get }
func startMonitoring()
func stopMonitoring()
```

A delegate `UserLocationProviderDelegate` will notify the state and data changes
```
func userLocationProvider(_ provider: UserLocationProvider, didReceive location: UserLocation)
func userLocationProviderAccessDenied(_ provider: UserLocationProvider)
func userLocationProviderAccessRestricted(_ provider: UserLocationProvider)
```

A separate interface `UserLocationProviderOverridable` based on UserLocationProvider provides the capabilities to override the user location
```
overrideUserLocation
```


#### Geofence
Data structure of a geofence

```
public let identifier: String
public let latitude: Double
public let longitude: Double
public let radius: Double
public let wifiSsid: String
public let coordinate: CLLocationCoordinate2D
public let region: CLCircularRegion
```

#### UserLocation
Data structure of a user location

```
public let latitude: Double?
public let longitude: Double?
public let wifiSsid: String?
public let coordinate: CLLocationCoordinate2D?
```

### Demo App
The demo app would act as an inteface for the user to customize GeofenceKit parameters to simulate its capabilities

### HomeView
Implemented using SwiftUI, the specification of the UI that interacts with HomeViewModel

#### HomeViewModel
HomeViewModel integrates `GeofenceKit` and `UserLocationProvider` and published events to notify state changes in HomeView

ViewModel makes it easy to write test cases using scenarios by mocking the interactions without needing the Views itself

Although for the purpose of this demo, I did not integrate any external framework to write proper scenario based test cases

## Potential Improvement
To provide a plug-n-play mechanism for the implementation using `GeofenceKitImp` protocol to inject the geofencing mechanism.

Then it is possible to swap between implementation of custom geofencing or apple flavoured geofencing without the need to modify extensively on GeofenceKit.

The implementation of timer in GoefenceKit can be also be moved out GeofenceKit, thus making the notification of entering/exit of region even more flexible as the implementation class itself can decide on the frequency of the interval instead of GeofenceKit or Policy. Policy interval could be lossly defined as something more vague such as the accuracy and let the implementation class decide the value of the accuracy through config or hardcoded values.

```
protocol GeofenceKitImpDelegate: class {
    func geofenceKitImp(
        _ geofenceKitImp: GeofenceKitImp, didEnter geofences: [Geofence])
    func geofenceKitImp(
        _ geofenceKitImp: GeofenceKitImp, didExit geofences: [Geofence])
}

protocol GeofenceKitImp {
    var delegate: GeofenceKitImpDelegate? { get }
    var userLocation: UserLocation? { get }
    var geofences: [Geofence] { get }
    var insideGeofences: [Geofence] { get }
    var policy: Policy { get }
    
    func startMonitoring()
    func stopMonitoring()
    
    func add(geofence: Geofence)
    func remove(geofence: Geofence)
    func removeAll()
}
```
