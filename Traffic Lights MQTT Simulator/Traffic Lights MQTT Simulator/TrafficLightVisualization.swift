//
//  TrafficLightVisualization.swift
//  Traffic Lights MQTT Simulator
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct TrafficLightVisualization: View {
    @ObservedObject var state: TrafficLightSimulatorState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Virtual Arduino Traffic Light")
                .font(.title2)
                .fontWeight(.bold)
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black)
                    .frame(width: 160, height: 380)
                
                VStack(spacing: 30) {
                    Circle()
                        .fill(state.redOn ? Color.red : Color.red.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .scaleEffect(state.redOn ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: state.redOn)
                    
                    Circle()
                        .fill(state.yellowOn ? Color.yellow : Color.yellow.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .scaleEffect(state.yellowOn ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: state.yellowOn)
                    
                    Circle()
                        .fill(state.greenOn ? Color.green : Color.green.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .scaleEffect(state.greenOn ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: state.greenOn)
                }
            }
            
            Text("Mode: \(state.mode)")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(modeColor.opacity(0.2))
                .foregroundColor(modeColor)
                .cornerRadius(20)
        }
    }
    
    private var modeColor: Color {
        switch state.mode {
        case "AUTO": return .blue
        case "MANUAL": return .orange
        case "FLASHING": return .purple
        case "OFF": return .gray
        default: return .gray
        }
    }
}