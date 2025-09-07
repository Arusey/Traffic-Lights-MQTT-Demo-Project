//
//  ContentView.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct TrafficLightApp_Previews: PreviewProvider {
    static var previews: some View {
        TrafficsLightsHomePage()
    }
}

struct TrafficsLightsHomePage: View {
    @StateObject private var trafficLightViewModel = DependencyContainer.shared.makeTrafficLightViewModel()
    @StateObject private var monitoringViewModel = DependencyContainer.shared.makeMonitoringViewModel()
    @StateObject private var settingsViewModel = DependencyContainer.shared.makeSettingsViewModel()
    
    var body: some View {
        TabView {
            TrafficControlView()
                .tabItem {
                    Image(systemName: "car.2")
                    Text("Control")
                }
                .environmentObject(trafficLightViewModel)
            
            MonitoringView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Monitor")
                }
                .environmentObject(monitoringViewModel)
                .environmentObject(trafficLightViewModel)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .environmentObject(settingsViewModel)
                .environmentObject(trafficLightViewModel)
                .environmentObject(monitoringViewModel)
        }
        .onAppear {
            trafficLightViewModel.connect()
        }
    }
}

