//
//  StatusCard.swift
//  Traffic Lights MQTT Simulator
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct StatusCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}