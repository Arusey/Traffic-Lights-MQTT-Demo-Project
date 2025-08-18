//
//  TrafficLightState.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import Foundation

struct TrafficLightState {
    var mode: TrafficLightMode = .off
    var redOn: Bool = false
    var yellowOn: Bool = false
    var greenOn: Bool = false
    var redDuration: Int = 7
    var yellowDuration: Int = 3
    var greenDuration: Int = 10
    var lastUpdate: Date = Date()
}