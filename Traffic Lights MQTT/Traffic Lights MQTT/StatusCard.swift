//
//  StatusCard.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct StatusCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}