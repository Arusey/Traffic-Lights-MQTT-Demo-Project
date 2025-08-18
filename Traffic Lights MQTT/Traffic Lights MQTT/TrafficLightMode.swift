//
//  TrafficLightMode.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import Foundation

enum TrafficLightMode: String, CaseIterable {
    case manual = "MANUAL"
    case auto = "AUTO"
    case off = "OFF"
    
    var displayName: String {
        switch self {
        case .manual: return "Manual"
        case .auto: return "Auto"
        case .off: return "Off"
        }
    }
}