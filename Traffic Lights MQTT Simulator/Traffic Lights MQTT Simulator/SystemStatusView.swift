//
//  SystemStatusView.swift
//  Traffic Lights MQTT Simulator
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct SystemStatusView: View {
    @ObservedObject var state: TrafficLightSimulatorState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("System Status")
                .font(.title3)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatusCard(title: "Uptime", value: formattedUptime, icon: "clock")
                StatusCard(title: "Mode", value: state.mode, icon: "gear")
                StatusCard(title: "Active Lights", value: activeLights, icon: "lightbulb.led")
                StatusCard(title: "Messages", value: "\(state.logMessages.count)", icon: "envelope")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var formattedUptime: String {
        let hours = Int(state.uptime) / 3600
        let minutes = (Int(state.uptime) % 3600) / 60
        let seconds = Int(state.uptime) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
    
    private var activeLights: String {
        let lights = [
            state.redOn ? "R" : nil,
            state.yellowOn ? "Y" : nil,
            state.greenOn ? "G" : nil
        ].compactMap { $0 }
        
        return lights.isEmpty ? "None" : lights.joined(separator: " ")
    }
}