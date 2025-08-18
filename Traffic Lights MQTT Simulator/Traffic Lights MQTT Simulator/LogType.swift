//
//  LogType.swift
//  Traffic Lights MQTT Simulator
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

enum LogType {
    case info, success, warning, error, mqtt
    
    var color: Color {
        switch self {
        case .info: return .primary
        case .success: return .green
        case .warning: return .orange
        case .error: return .red
        case .mqtt: return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .info: return "info.circle"
        case .success: return "checkmark.circle"
        case .warning: return "exclamationmark.triangle"
        case .error: return "xmark.circle"
        case .mqtt: return "network"
        }
    }
}