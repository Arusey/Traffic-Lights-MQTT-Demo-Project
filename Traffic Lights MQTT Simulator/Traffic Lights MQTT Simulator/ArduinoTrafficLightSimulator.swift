//
//  ArduinoTrafficLightSimulator.swift
//  Traffic Lights MQTT Simulator
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI
import CocoaMQTT
import Combine

class ArduinoTrafficLightSimulator: ObservableObject {
    @Published var state = TrafficLightSimulatorState()
    
    private var mqtt: CocoaMQTT?
    private var autoTimer: Timer?
    private var flashTimer: Timer?
    private var statusTimer: Timer?
    private var uptimeTimer: Timer?
    private var autoPhase: Int = 0
    private var phaseStartTime: Date = Date()
    private let startTime = Date()
    
    private var host: String = "localhost"
    private var port: UInt16 = 1883
    private var username: String = ""
    private var password: String = ""
    private let clientID = "swift_arduino_simulator"
    
    init() {
        loadMQTTConfig()
        setupUptimeTimer()
        state.addLog("Arduino Traffic Light Simulator Started", type: .success)
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
    
    private func setupUptimeTimer() {
        uptimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.state.uptime = Date().timeIntervalSince(self.startTime)
        }
    }
    
    func connect() {
        if let existingMqtt = mqtt {
            existingMqtt.disconnect()
            mqtt = nil
        }
        
        state.addLog("Connecting to MQTT broker at \(host):\(port)", type: .info)
        
        mqtt = CocoaMQTT(clientID: clientID, host: host, port: port)
        if !username.isEmpty {
            mqtt?.username = username
        }
        if !password.isEmpty {
            mqtt?.password = password
        }
        mqtt?.keepAlive = 60
        mqtt?.autoReconnect = false
        mqtt?.delegate = self
        mqtt?.willMessage = CocoaMQTTMessage(topic: "traffic/status/connection", string: "OFFLINE", qos: .qos0, retained: true)
        
        guard let mqtt = mqtt else {
            state.addLog("Failed to create MQTT client", type: .error)
            return
        }
        
        state.addLog("Attempting connection...", type: .info)
        let result = mqtt.connect(timeout: 10)
        if !result {
            state.addLog("Failed to initiate connection", type: .error)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            if !self.state.isConnected {
                self.state.addLog("Connection timeout - check broker availability", type: .error)
                self.state.connectionStatus = "Connection Timeout"
            }
        }
    }
    
    func disconnect() {
        stopAllTimers()
        mqtt?.disconnect()
        state.connectionStatus = "Disconnected"
        state.isConnected = false
        state.addLog("Disconnected from MQTT broker", type: .warning)
    }
    
    private func setMode(_ mode: String) {
        state.addLog("Switching to \(mode) mode", type: .info)
        stopAllTimers()
        
        state.mode = mode
        
        switch mode {
        case "MANUAL":
            break
        case "AUTO":
            startAutoSequence()
        case "FLASHING":
            startFlashing()
        case "OFF":
            state.redOn = false
            state.yellowOn = false
            state.greenOn = false
            state.addLog("All lights turned off", type: .info)
        default:
            break
        }
        
        publishStatus()
    }
    
    private func startAutoSequence() {
        state.addLog("Starting automatic sequence", type: .success)
        
        state.redOn = false
        state.yellowOn = false
        state.greenOn = true
        autoPhase = 0
        phaseStartTime = Date()
        
        state.addLog("Green light - Duration: \(state.greenDuration)s", type: .success)
        
        autoTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.autoSequenceTick()
        }
        
        publishStatus()
    }
    
    private func autoSequenceTick() {
        guard state.mode == "AUTO" else { return }
        
        let currentTime = Date()
        var phaseDuration: Int = 0
        
        switch autoPhase {
        case 0: phaseDuration = state.greenDuration
        case 1: phaseDuration = state.yellowDuration
        case 2: phaseDuration = state.redDuration
        default: break
        }
        
        if currentTime.timeIntervalSince(phaseStartTime) >= TimeInterval(phaseDuration) {
            autoPhase = (autoPhase + 1) % 3
            phaseStartTime = currentTime
            
            switch autoPhase {
            case 0:
                state.redOn = false
                state.yellowOn = false
                state.greenOn = true
                state.addLog("Green light - Duration: \(state.greenDuration)s", type: .success)
            case 1:
                state.redOn = false
                state.yellowOn = true
                state.greenOn = false
                state.addLog("Yellow light - Duration: \(state.yellowDuration)s", type: .warning)
            case 2:
                state.redOn = true
                state.yellowOn = false
                state.greenOn = false
                state.addLog("Red light - Duration: \(state.redDuration)s", type: .error)
            default:
                break
            }
            
            publishStatus()
        }
    }
    
    private func startFlashing() {
        state.addLog("Starting flashing \(state.flashColor) mode", type: .warning)
        
        state.redOn = false
        state.yellowOn = false
        state.greenOn = false
        
        flashTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(state.flashInterval) / 1000.0, repeats: true) { [weak self] _ in
            self?.flashTick()
        }
    }
    
    private func flashTick() {
        guard state.mode == "FLASHING" else { return }
        
        switch state.flashColor {
        case "RED":
            state.redOn.toggle()
        case "YELLOW":
            state.yellowOn.toggle()
        case "GREEN":
            state.greenOn.toggle()
        default:
            break
        }
        
        publishStatus()
    }
    
    private func stopAllTimers() {
        autoTimer?.invalidate()
        autoTimer = nil
        flashTimer?.invalidate()
        flashTimer = nil
    }
    
    private func publishStatus() {
        guard let mqtt = mqtt, state.isConnected else { return }
        
        mqtt.publish("traffic/status/red", withString: state.redOn ? "ON" : "OFF", qos: .qos0)
        mqtt.publish("traffic/status/yellow", withString: state.yellowOn ? "ON" : "OFF", qos: .qos0)
        mqtt.publish("traffic/status/green", withString: state.greenOn ? "ON" : "OFF", qos: .qos0)
        
        mqtt.publish("traffic/status/mode", withString: state.mode, qos: .qos0)
        
        let lightsStatus = [
            "red": state.redOn,
            "yellow": state.yellowOn,
            "green": state.greenOn
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: lightsStatus),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            mqtt.publish("traffic/status/lights", withString: jsonString, qos: .qos0)
        }
        
        let systemStatus = [
            "mode": state.mode,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "uptime": Int(state.uptime),
            "simulator": "swift-macos"
        ] as [String : Any]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: systemStatus),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            mqtt.publish("traffic/status/system", withString: jsonString, qos: .qos0)
        }
    }
    
    private func startStatusPublishing() {
        statusTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.publishStatus()
        }
    }
}

extension ArduinoTrafficLightSimulator: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        DispatchQueue.main.async {
            if ack == .accept {
                self.state.connectionStatus = "Connected"
                self.state.isConnected = true
                self.state.addLog("Connected to MQTT broker", type: .success)
                
                let topics = [
                    "traffic/mode",
                    "traffic/red",
                    "traffic/yellow", 
                    "traffic/green",
                    "traffic/timing/+",
                    "traffic/flash/+"
                ]
                
                for topic in topics {
                    mqtt.subscribe(topic, qos: .qos1)
                    self.state.addLog("Subscribed to \(topic)", type: .mqtt)
                }
                
                mqtt.publish("traffic/status/connection", withString: "ONLINE", qos: .qos0, retained: true)
                
                self.startStatusPublishing()
                self.publishStatus()
                
            } else {
                self.state.connectionStatus = "Connection Failed"
                self.state.isConnected = false
                self.state.addLog("Connection failed: \(ack)", type: .error)
            }
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        let topic = message.topic
        let payload = message.string ?? ""
        
        DispatchQueue.main.async {
            self.state.addLog("Received: \(topic) = \(payload)", type: .mqtt)
            
            switch topic {
            case "traffic/mode":
                self.setMode(payload)
                
            case "traffic/red":
                if self.state.mode == "MANUAL" {
                    self.state.redOn = (payload == "ON")
                    self.state.addLog("🔴 Red light: \(payload)", type: payload == "ON" ? .error : .info)
                    self.publishStatus()
                }
                
            case "traffic/yellow":
                if self.state.mode == "MANUAL" {
                    self.state.yellowOn = (payload == "ON")
                    self.state.addLog("🟡 Yellow light: \(payload)", type: payload == "ON" ? .warning : .info)
                    self.publishStatus()
                }
                
            case "traffic/green":
                if self.state.mode == "MANUAL" {
                    self.state.greenOn = (payload == "ON")
                    self.state.addLog("🟢 Green light: \(payload)", type: payload == "ON" ? .success : .info)
                    self.publishStatus()
                }
                
            case "traffic/timing/red":
                if let duration = Int(payload) {
                    self.state.redDuration = duration
                    self.state.addLog("Set red duration to \(duration)s", type: .info)
                }
                
            case "traffic/timing/yellow":
                if let duration = Int(payload) {
                    self.state.yellowDuration = duration
                    self.state.addLog("Set yellow duration to \(duration)s", type: .info)
                }
                
            case "traffic/timing/green":
                if let duration = Int(payload) {
                    self.state.greenDuration = duration
                    self.state.addLog("Set green duration to \(duration)s", type: .info)
                }
                
            case "traffic/flash/color":
                self.state.flashColor = payload
                self.state.addLog("Set flash color to \(payload)", type: .warning)
                if self.state.mode == "FLASHING" {
                    self.startFlashing()
                }
                
            case "traffic/flash/interval":
                if let interval = Int(payload) {
                    self.state.flashInterval = interval
                    self.state.addLog("Set flash interval to \(interval)ms", type: .warning)
                    if self.state.mode == "FLASHING" {
                        self.startFlashing()
                    }
                }
                
            default:
                break
            }
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
            self.state.connectionStatus = "Disconnected"
            self.state.isConnected = false
            self.stopAllTimers()
            
            if let error = err {
                let nsError = error as NSError
                self.state.addLog("Disconnected with error: \(error.localizedDescription)", type: .error)
                self.state.addLog("Error details: Domain=\(nsError.domain), Code=\(nsError.code)", type: .error)
                
                if nsError.code == 1 {
                    self.state.addLog("Tip: Check if MQTT broker is running and accessible", type: .warning)
                } else if nsError.code == 61 {
                    self.state.addLog("Tip: Connection refused - check broker port and firewall", type: .warning)
                } else if nsError.code == -1009 {
                    self.state.addLog("Tip: No internet connection available", type: .warning)
                }
            } else {
                self.state.addLog("Disconnected from MQTT broker", type: .warning)
            }
        }
    }
}