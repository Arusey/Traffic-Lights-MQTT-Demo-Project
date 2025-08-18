//
//  MQTTMessage.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import Foundation

struct MQTTMessage: Identifiable {
    let id = UUID()
    let topic: String
    let payload: String
    let timestamp: Date
    let isOutgoing: Bool
}