//
//  MonitoringView.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct MonitoringView: View {
    @EnvironmentObject var mqttManager: TrafficLightMQTTManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        StatusCard(
                            title: "Connection",
                            value: mqttManager.connectionStatus,
                            icon: "wifi",
                            color: mqttManager.isConnected ? .green : .red
                        )
                        
                        StatusCard(
                            title: "Current Mode",
                            value: mqttManager.trafficLightState.mode.displayName,
                            icon: "stoplights",
                            color: .blue
                        )
                        
                        StatusCard(
                            title: "Active Lights",
                            value: activeLightsText,
                            icon: "lightbulb.led",
                            color: .orange
                        )
                        
                        StatusCard(
                            title: "Last Update",
                            value: timeString(from: mqttManager.trafficLightState.lastUpdate),
                            icon: "clock",
                            color: .purple
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("MQTT Messages")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(mqttManager.receivedMessages.count) messages")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if mqttManager.receivedMessages.isEmpty {
                            Text("No messages yet")
                                .foregroundColor(.gray)
                                .italic()
                                .padding()
                        } else {
                            ForEach(mqttManager.receivedMessages.prefix(20)) { message in
                                MessageRow(message: message)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                }
                .padding()
            }
            .navigationTitle("Monitor")
            .refreshable {
                print("Refreshing...")
            }
        }
    }
    
    private var activeLightsText: String {
        let lights = [
            mqttManager.trafficLightState.redOn ? "Red" : nil,
            mqttManager.trafficLightState.yellowOn ? "Yellow" : nil,
            mqttManager.trafficLightState.greenOn ? "Green" : nil
        ].compactMap { $0 }
        
        return lights.isEmpty ? "None" : lights.joined(separator: ", ")
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}