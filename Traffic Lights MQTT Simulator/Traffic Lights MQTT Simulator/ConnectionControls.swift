//
//  ConnectionControls.swift
//  Traffic Lights MQTT Simulator
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct ConnectionControls: View {
    let simulator: ArduinoTrafficLightSimulator
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Circle()
                    .fill(simulator.state.isConnected ? .green : .red)
                    .frame(width: 12, height: 12)
                
                Text(simulator.state.connectionStatus)
                    .font(.headline)
                
                Spacer()
            }
            
            HStack(spacing: 10) {
                Button(simulator.state.isConnected ? "Disconnect" : "Connect") {
                    if simulator.state.isConnected {
                        simulator.disconnect()
                    } else {
                        simulator.connect()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(simulator.state.isConnected ? .red : .green)
                
                Button("Clear Logs") {
                    simulator.state.logMessages.removeAll()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}