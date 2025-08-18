//
//  LogView.swift
//  Traffic Lights MQTT Simulator
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct LogView: View {
    @ObservedObject var state: TrafficLightSimulatorState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("System Logs")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(state.logMessages.count) messages")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(state.logMessages) { message in
                        LogMessageRow(message: message)
                    }
                }
                .padding(.horizontal, 8)
            }
            .background(Color.black.opacity(0.05))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}