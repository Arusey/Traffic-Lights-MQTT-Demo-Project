//
//  LogMessageRow.swift
//  Traffic Lights MQTT Simulator
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

struct LogMessageRow: View {
    let message: LogMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: message.type.icon)
                .foregroundColor(message.type.color)
                .font(.caption)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(message.message)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(message.type.color)
                
                Text(timeString(from: message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}