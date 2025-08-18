//
//  LogMessage.swift
//  Traffic Lights MQTT Simulator
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import Foundation

struct LogMessage: Identifiable {
    let id = UUID()
    let message: String
    let type: LogType
    let timestamp: Date
}