//
//  AutoControlsView.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct AutoControlsView: View {
    @EnvironmentObject var mqttManager: TrafficLightMQTTManager
    @State private var redDuration: Double = 7
    @State private var yellowDuration: Double = 3
    @State private var greenDuration: Double = 10
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Automatic Mode Settings")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                    Text("Red Duration: \(Int(redDuration))s")
                        .font(.headline)
                    Spacer()
                }
                
                Slider(value: $redDuration, in: 3...15, step: 1)
                    .onChange(of: redDuration) { value in
                        mqttManager.setTiming(red: Int(value))
                    }
                
                HStack {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 20, height: 20)
                    Text("Yellow Duration: \(Int(yellowDuration))s")
                        .font(.headline)
                    Spacer()
                }
                
                Slider(value: $yellowDuration, in: 1...5, step: 1)
                    .onChange(of: yellowDuration) { value in
                        mqttManager.setTiming(yellow: Int(value))
                    }
                
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 20, height: 20)
                    Text("Green Duration: \(Int(greenDuration))s")
                        .font(.headline)
                    Spacer()
                }
                
                Slider(value: $greenDuration, in: 5...20, step: 1)
                    .onChange(of: greenDuration) { value in
                        mqttManager.setTiming(green: Int(value))
                    }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(15)
    }
}
