//
//  TrafficControlView.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct TrafficControlView: View {
    @EnvironmentObject var mqttManager: TrafficLightMQTTManager
    @State private var selectedMode: TrafficLightMode = .off
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    ConnectionStatusCard()
                    
                    TrafficLightView(state: mqttManager.trafficLightState)
                    
                    VStack(spacing: 15) {
                        Text("Control Mode")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Picker("Mode", selection: $selectedMode) {
                            ForEach(TrafficLightMode.allCases, id: \.self) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedMode) { newMode in
                            mqttManager.setMode(newMode)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(15)
                    
                    if selectedMode == .manual {
                        ManualControlsView()
                    }
                    
                    if selectedMode == .auto {
                        AutoControlsView()
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Traffic Light Control")
        }
    }
}