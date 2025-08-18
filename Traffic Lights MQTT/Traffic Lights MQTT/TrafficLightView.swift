//
//  TrafficLightView.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct TrafficLightView: View {
    let state: TrafficLightState
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Traffic Light Status")
                .font(.title2)
                .fontWeight(.semibold)
            
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.black)
                    .frame(width: 140, height: 320)
                
                VStack(spacing: 25) {
                    Circle()
                        .fill(state.redOn ? Color.red : Color.red.opacity(0.2))
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .scaleEffect(state.redOn ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: state.redOn)
                    
                    Circle()
                        .fill(state.yellowOn ? Color.yellow : Color.yellow.opacity(0.2))
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .scaleEffect(state.yellowOn ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: state.yellowOn)
                    
                    Circle()
                        .fill(state.greenOn ? Color.green : Color.green.opacity(0.2))
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .scaleEffect(state.greenOn ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: state.greenOn)
                }
            }
            
            Text("Mode: \(state.mode.displayName)")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}