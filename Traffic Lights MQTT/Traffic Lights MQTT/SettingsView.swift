//
//  SettingsView.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var mqttManager: TrafficLightMQTTManager
    
    var body: some View {
        NavigationView {
            List { 
                Section("Connection") {
                    HStack {
                        Image(systemName: "wifi")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("MQTT Broker")
                                .font(.headline)
                            Text(mqttManager.connectionStatus)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    
                }
                
                Section("Actions") {
                    Button("Reconnect") {
                        mqttManager.disconnect()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            mqttManager.connect()
                        }
                    }
                    
                    Button("Clear Messages") {
                        mqttManager.receivedMessages.removeAll()
                    }
                    
                    Button("Emergency Stop") {
                        mqttManager.setMode(.off)
                    }
                    .foregroundColor(.red)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("MQTT Protocol")
                        Spacer()
                        Text("3.1.1")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
