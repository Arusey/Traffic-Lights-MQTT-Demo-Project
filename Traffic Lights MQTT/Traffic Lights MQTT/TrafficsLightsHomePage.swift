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
    @StateObject private var mqttManager = TrafficLightMQTTManager()
    
    var body: some View {
        TabView {
            TrafficControlView()
                .tabItem {
                    Image(systemName: "car.2")
                    Text("Control")
                }
                .environmentObject(mqttManager)
            
            MonitoringView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Monitor")
                }
                .environmentObject(mqttManager)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .environmentObject(mqttManager)
        }
        .onAppear {
            mqttManager.connect()
        }
    }
}

