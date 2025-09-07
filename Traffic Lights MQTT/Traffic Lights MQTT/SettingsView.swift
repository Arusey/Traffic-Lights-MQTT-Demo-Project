//
//  SettingsView.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @EnvironmentObject var trafficLightViewModel: TrafficLightViewModel
    @EnvironmentObject var monitoringViewModel: MonitoringViewModel
    
    var body: some View {
        NavigationView {
            List { 
                Section("Connection Settings") {
                    HStack {
                        Text("Host")
                        Spacer()
                        TextField("Host", text: $viewModel.mqttHost)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 150)
                    }
                    
                    HStack {
                        Text("Port")
                        Spacer()
                        TextField("Port", text: $viewModel.mqttPort)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 80)
                    }
                    
                    HStack {
                        Text("Username")
                        Spacer()
                        TextField("Username", text: $viewModel.mqttUsername)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 150)
                    }
                    
                    HStack {
                        Text("Password")
                        Spacer()
                        SecureField("Password", text: $viewModel.mqttPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 150)
                    }
                }
                
                Section("Connection Status") {
                    HStack {
                        Image(systemName: "wifi")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("MQTT Broker")
                                .font(.headline)
                            Text(viewModel.connectionStatus)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                
                Section("Actions") {
                    Button("Test Connection") {
                        viewModel.testConnection()
                    }
                    .disabled(!viewModel.isValidConfiguration)
                    
                    Button("Reconnect") {
                        viewModel.disconnect()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            trafficLightViewModel.connect()
                        }
                    }
                    
                    Button("Clear Messages") {
                        monitoringViewModel.clearMessages()
                    }
                    
                    Button("Emergency Stop") {
                        trafficLightViewModel.setMode(.off)
                    }
                    .foregroundColor(.red)
                    
                    Button("Save Configuration") {
                        viewModel.saveConfiguration()
                    }
                    .disabled(!viewModel.isValidConfiguration)
                    
                    Button("Reset to Defaults") {
                        viewModel.resetToDefaults()
                    }
                    .foregroundColor(.orange)
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
