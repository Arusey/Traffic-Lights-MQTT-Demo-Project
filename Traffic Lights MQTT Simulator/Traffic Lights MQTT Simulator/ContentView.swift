//
//  ContentView.swift
//  Traffic Lights MQTT Simulator
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI
struct ContentView: View {
    @StateObject private var simulator = ArduinoTrafficLightSimulator()
    
    var body: some View {
        HSplitView {
            VStack(spacing: 20) {
                TrafficLightVisualization(state: simulator.state)
                
                ConnectionControls(simulator: simulator)
                
                Spacer()
            }
            .frame(minWidth: 300, maxWidth: 400)
            .padding()
            
            VStack(spacing: 15) {
                SystemStatusView(state: simulator.state)
                
                LogView(state: simulator.state)
            }
            .frame(minWidth: 400)
            .padding()
        }
        .frame(minWidth: 800, minHeight: 600)
        .navigationTitle("Arduino Traffic Light Simulator")
    }
}

#Preview {
    ContentView()
}
