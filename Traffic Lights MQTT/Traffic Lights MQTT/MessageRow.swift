//
//  MessageRow.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct MessageRow: View {
    let message: MQTTMessage
    
    var body: some View {
        HStack {
            Image(systemName: message.isOutgoing ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .foregroundColor(message.isOutgoing ? .blue : .green)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(message.topic)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(timeString(from: message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Text(message.payload)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}