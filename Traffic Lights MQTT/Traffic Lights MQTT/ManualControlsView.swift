//
//  ManualControlsView.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct ManualControlsView: View {
    @EnvironmentObject var viewModel: TrafficLightViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Manual Control")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.setLight(.red, on: !viewModel.trafficLightState.redOn)
                }) {
                    VStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 50, height: 50)
                        Text("Red")
                            .font(.caption)
                        Text(viewModel.trafficLightState.redOn ? "ON" : "OFF")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    viewModel.setLight(.yellow, on: !viewModel.trafficLightState.yellowOn)
                }) {
                    VStack {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 50, height: 50)
                        Text("Yellow")
                            .font(.caption)
                        Text(viewModel.trafficLightState.yellowOn ? "ON" : "OFF")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    viewModel.setLight(.green, on: !viewModel.trafficLightState.greenOn)
                }) {
                    VStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 50, height: 50)
                        Text("Green")
                            .font(.caption)
                        Text(viewModel.trafficLightState.greenOn ? "ON" : "OFF")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(15)
    }
}