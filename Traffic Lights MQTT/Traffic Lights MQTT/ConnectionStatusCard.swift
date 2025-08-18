//
//  ConnectionStatusCard.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct ConnectionStatusCard: View {
    @EnvironmentObject var mqttManager: TrafficLightMQTTManager
    
    var body: some View {
        HStack {
            Circle()
                .fill(connectionStatusColor)
                .frame(width: 12, height: 12)
            
            Text(mqttManager.connectionStatus)
                .font(.headline)
            
            Spacer()
            
            if !mqttManager.isConnected {
                Button("Retry") {
                    mqttManager.connect()
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var connectionStatusColor: Color {
        switch mqttManager.connectionStatus {
        case "Connected":
            return .green
        case "Disconnected":
            return .red
        default:
            return .orange
        }
    }
}