//
//  TrafficLightSimulatorState.swift
//  Traffic Lights MQTT Simulator
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

class TrafficLightSimulatorState: ObservableObject {
    @Published var mode: String = "OFF"
    @Published var redOn: Bool = false
    @Published var yellowOn: Bool = false
    @Published var greenOn: Bool = false
    @Published var redDuration: Int = 7
    @Published var yellowDuration: Int = 3
    @Published var greenDuration: Int = 10
    @Published var flashColor: String = "YELLOW"
    @Published var flashInterval: Int = 500
    @Published var connectionStatus: String = "Disconnected"
    @Published var isConnected: Bool = false
    @Published var logMessages: [LogMessage] = []
    @Published var uptime: TimeInterval = 0
    
    func addLog(_ message: String, type: LogType = .info) {
        let logMessage = LogMessage(message: message, type: type, timestamp: Date())
        DispatchQueue.main.async {
            self.logMessages.insert(logMessage, at: 0)
            if self.logMessages.count > 100 {
                self.logMessages.removeLast()
            }
        }
    }
}