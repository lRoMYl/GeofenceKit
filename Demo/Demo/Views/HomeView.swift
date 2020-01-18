// Copyright © 2020 Carousell. All rights reserved.
// 

import SwiftUI
import GeofenceKit
import Combine

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var currentHeight: CGFloat = 0
    
    var body: some View {
        List {
            Section(header: Text(viewModel.sectionGeofenceHeader)) {
                HStack() {
                    Text(viewModel.wifiSsidTitle)
                    TextField(viewModel.wifiSsidPlaceholder, text: $viewModel.wifiSsid)
                    .disabled(viewModel.monitoring)
                }
                VStack {
                    Text(viewModel.latitudeTitle)
                    HStack {
                        Text(viewModel.minLatitudeText)
                        Slider(
                            value: $viewModel.latitude,
                            in: viewModel.validLatitudeRanges)
                            .disabled(viewModel.monitoring)
                        Text(viewModel.maxLatitudeText)
                    }
                }
                VStack {
                    Text(viewModel.longitudeTitle)
                    HStack {
                        Text(viewModel.minLongitudeText)
                        Slider(
                            value: $viewModel.longitude,
                            in: viewModel.validLongitudeRanges)
                            .disabled(viewModel.monitoring)
                        Text(viewModel.maxLongitudeText)
                    }
                }
                VStack {
                    Text(viewModel.radiusTitle)
                    HStack {
                        Text(viewModel.minRadiusText)
                        Slider(
                            value: $viewModel.radius,
                            in: viewModel.validRadiusRanges)
                            .disabled(viewModel.monitoring)
                        Text(viewModel.maxRadiusText)
                    }
                }
                Button(viewModel.monitorButtonTitle) {
                    self.viewModel.onTapMonitor()
                }
                Button(viewModel.copyUserLocationButtonTitle) {
                    self.viewModel.onTapCopyUserLocation()
                }
            }
            
            Section(header: Text(viewModel.sectionUserHeader)) {
                VStack() {
                    Toggle(isOn: $viewModel.userLocationOverride) {
                        Text(viewModel.userOverrideTitle)
                    }
                    HStack() {
                        Text(viewModel.wifiSsidTitle)
                        TextField(viewModel.wifiSsidPlaceholder, text: $viewModel.userWifi)
                        .disabled(!viewModel.userLocationOverride)
                    }
                    VStack {
                        Text(viewModel.userLatitudeTitle)
                        HStack {
                            Text(viewModel.minLatitudeText)
                            Slider(
                                value: $viewModel.userLatitude,
                                in: viewModel.validLatitudeRanges)
                                .disabled(!viewModel.userLocationOverride)
                            Text(viewModel.maxLatitudeText)
                        }
                    }
                    VStack {
                        Text(viewModel.userLongitudeTitle)
                        HStack {
                            Text(viewModel.minLongitudeText)
                            Slider(
                                value: $viewModel.userLongitude,
                                in: viewModel.validLongitudeRanges)
                                .disabled(!viewModel.userLocationOverride)
                            Text(viewModel.maxLongitudeText)
                        }
                    }
                }
                
                if viewModel.title.count > 0 {
                    Text(viewModel.title)
                }
            }
        }
            .listStyle(GroupedListStyle())
            .alert(isPresented: $viewModel.showAlert) { () -> Alert in
                Alert(
                    title: Text(viewModel.alertType.title),
                    message: Text(viewModel.alertType.text),
                    dismissButton: .cancel(Text("Ok")))
            }
            .padding(.bottom, currentHeight).animation(.easeOut(duration: 0.25))
            .edgesIgnoringSafeArea(currentHeight == 0 ? Edge.Set() : .bottom)
            .onAppear(perform: subscribeToKeyboardChanges)
    }
    
    /*
     Snippet for Keyboard handling
     https://forums.developer.apple.com/thread/120763
     */
    //MARK: - Keyboard Height
    private let keyboardHeightOnOpening = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .map { $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect }
        .map { $0.height > 333 ? $0.height : 333 }
    
    private let keyboardHeightOnHiding = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map {_ in return CGFloat(0) }
    
    //MARK: - Subscriber to Keyboard's changes
    private func subscribeToKeyboardChanges() {
        _ = Publishers.Merge(keyboardHeightOnOpening, keyboardHeightOnHiding)
            .subscribe(on: RunLoop.main)
            .sink { height in
                print("Height: \(height)")
                if self.currentHeight == 0 || height == 0 {
                    self.currentHeight = height
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel(
            policy: DefaultPolicy(),
            userLocationProvider: DefaultUserLocationProvider(),
            overrideUserLocationProvider: DefaultUserLocationProvider()))
    }
}
