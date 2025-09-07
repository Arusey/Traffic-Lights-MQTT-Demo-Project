//
//  ConnectionControls.swift
//  Traffic Lights MQTT Simulator
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct ConnectionControls: View {
    let viewModel: SimulatorViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Circle()
                    .fill(viewModel.state.isConnected ? .green : .red)
                    .frame(width: 12, height: 12)
                
                Text(viewModel.state.connectionStatus)
                    .font(.headline)
                
                Spacer()
            }
            
            HStack(spacing: 10) {
                Button(viewModel.state.isConnected ? "Disconnect" : "Connect") {
                    if viewModel.state.isConnected {
                        viewModel.disconnect()
                    } else {
                        viewModel.connect()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.state.isConnected ? .red : .green)
                
                Button("Clear Logs") {
                    viewModel.state.logMessages.removeAll()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}