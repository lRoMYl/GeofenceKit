// Copyright © 2020 Carousell. All rights reserved.
// 

import SwiftUI
import GeofenceKit

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
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
