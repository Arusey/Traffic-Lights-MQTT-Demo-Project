//
//  TrafficLightMQTTManager.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import Foundation
import SwiftUI
import CocoaMQTT

class TrafficLightMQTTManager: ObservableObject {
    @Published var connectionStatus: String = "Disconnected"
    @Published var receivedMessages: [MQTTMessage] = []
    @Published var trafficLightState = TrafficLightState()
    @Published var isConnected = false
    
    private var mqtt: CocoaMQTT?
    
    private var host: String = "localhost"
    private var port: UInt16 = 1883
    private var username: String = ""
    private var password: String = ""
    private let clientID = "ios_traffic_\(UUID().uuidString)"
    
    init() {
        loadMQTTConfig()
    }
    
    private func loadMQTTConfig() {
        guard let url = Bundle.main.url(forResource: "mqtt-config", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let config = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("Failed to load MQTT config, using defaults")
            return
        }
        
        host = config["host"] as? String ?? "localhost"
        port = UInt16(config["port"] as? Int ?? 1883)
        username = config["username"] as? String ?? ""
        password = config["password"] as? String ?? ""
    }
    
    
    func connect() {
        mqtt = CocoaMQTT(clientID: clientID, host: host, port: port)
        mqtt?.username = username
        mqtt?.password = password
        mqtt?.keepAlive = 60
        mqtt?.delegate = self
        
        guard let mqtt = mqtt else { return }
        _ = mqtt.connect()
    }
    
    func disconnect() {
        mqtt?.disconnect()
        isConnected = false
    }
    
    func publish(topic: String, message: String) {
        mqtt?.publish(topic, withString: message, qos: .qos1)
        addMessage(topic: topic, payload: message, isOutgoing: true)
    }
    
    private func addMessage(topic: String, payload: String, isOutgoing: Bool) {
        let message = MQTTMessage(
            topic: topic,
            payload: payload,
            timestamp: Date(),
            isOutgoing: isOutgoing
        )
        receivedMessages.insert(message, at: 0)
        
        if receivedMessages.count > 50 {
            receivedMessages.removeLast()
        }
    }
    
    func setMode(_ mode: TrafficLightMode) {
        publish(topic: "traffic/mode", message: mode.rawValue)
    }
    
    func setLight(_ color: LightColor, on: Bool) {
        let command = on ? "ON" : "OFF"
        
        switch color {
        case .red:
            trafficLightState.redOn = on
        case .yellow:
            trafficLightState.yellowOn = on
        case .green:
            trafficLightState.greenOn = on
        }
        trafficLightState.lastUpdate = Date()
        
        publish(topic: "traffic/\(color.rawValue.lowercased())", message: command)
    }
    
    func setTiming(red: Int? = nil, yellow: Int? = nil, green: Int? = nil) {
        if let red = red {
            publish(topic: "traffic/timing/red", message: "\(red)")
        }
        if let yellow = yellow {
            publish(topic: "traffic/timing/yellow", message: "\(yellow)")
        }
        if let green = green {
            publish(topic: "traffic/timing/green", message: "\(green)")
        }
    }
}

extension TrafficLightMQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        DispatchQueue.main.async {
            self.connectionStatus = ack == .accept ? "Connected" : "Connection Failed"
            self.isConnected = ack == .accept
        }
        
        if ack == .accept {
            mqtt.subscribe("traffic/status/+", qos: .qos1)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        let topic = message.topic
        let payload = message.string ?? ""
        
        DispatchQueue.main.async {
            self.addMessage(topic: topic, payload: payload, isOutgoing: false)
            
            switch topic {
            case "traffic/status/mode":
                if let mode = TrafficLightMode(rawValue: payload) {
                    self.trafficLightState.mode = mode
                }
            case "traffic/status/lights":
                if let data = payload.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Bool] {
                    self.trafficLightState.redOn = json["red"] ?? false
                    self.trafficLightState.yellowOn = json["yellow"] ?? false
                    self.trafficLightState.greenOn = json["green"] ?? false
                }
            case "traffic/status/red":
                self.trafficLightState.redOn = (payload == "ON")
            case "traffic/status/yellow":
                self.trafficLightState.yellowOn = (payload == "ON")
            case "traffic/status/green":
                self.trafficLightState.greenOn = (payload == "ON")
            default:
                break
            }
            
            self.trafficLightState.lastUpdate = Date()
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {}
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {}
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {}
    func mqttDidPing(_ mqtt: CocoaMQTT) {}
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        DispatchQueue.main.async {
            self.connectionStatus = "Disconnected"
            self.isConnected = false
        }
    }
}