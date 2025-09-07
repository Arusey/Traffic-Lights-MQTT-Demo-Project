//
//  SimulatorViewModel.swift
//  Traffic Lights MQTT Simulator
//
//  ViewModel for Arduino traffic light simulator business logic
//

import Foundation
import Combine
import CocoaMQTT

class SimulatorViewModel: ObservableObject {
    @Published var state = TrafficLightSimulatorState()
    
    private let mqttRepository: MQTTRepositoryProtocol
    private let configRepository: ConfigurationRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var autoTimer: Timer?
    private var flashTimer: Timer?
    private var statusTimer: Timer?
    private var uptimeTimer: Timer?
    private var autoPhase: Int = 0
    private var phaseStartTime: Date = Date()
    private let startTime = Date()
    
    init(mqttRepository: MQTTRepositoryProtocol = MQTTRepository(),
         configRepository: ConfigurationRepositoryProtocol = ConfigurationRepository()) {
        self.mqttRepository = mqttRepository
        self.configRepository = configRepository
        
        setupBindings()
        setupUptimeTimer()
        state.addLog("Arduino Traffic Light Simulator Started", type: .success)
    }
    
    private func setupBindings() {
        mqttRepository.connectionStatus
            .assign(to: \.state.connectionStatus, on: self)
            .store(in: &cancellables)
        
        mqttRepository.isConnected
            .assign(to: \.state.isConnected, on: self)
            .store(in: &cancellables)
        
        mqttRepository.messageReceived()
            .sink { [weak self] topic, payload in
                self?.handleMQTTMessage(topic: topic, payload: payload)
            }
            .store(in: &cancellables)
    }
    
    private func setupUptimeTimer() {
        uptimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.state.uptime = Date().timeIntervalSince(self.startTime)
        }
    }
    
    func connect() {
        guard let config = configRepository.loadMQTTConfiguration() else {
            state.addLog("Failed to load configuration", type: .error)
            return
        }
        
        state.addLog("Connecting to MQTT broker at \(config.host):\(config.port)", type: .info)
        
        mqttRepository.connect(
            host: config.host,
            port: config.port,
            username: config.username,
            password: config.password
        )
        .sink { [weak self] success in
            if success {
                self?.state.addLog("Connected to MQTT broker", type: .success)
                self?.startStatusPublishing()
                self?.publishStatus()
            } else {
                self?.state.addLog("Connection timeout - check broker availability", type: .error)
                self?.state.connectionStatus = "Connection Timeout"
            }
        }
        .store(in: &cancellables)
    }
    
    func disconnect() {
        stopAllTimers()
        mqttRepository.disconnect()
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
        statusTimer?.invalidate()
        statusTimer = nil
    }
    
    private func publishStatus() {
        guard state.isConnected else { return }
        
        mqttRepository.publish(topic: "traffic/status/red", message: state.redOn ? "ON" : "OFF", qos: .qos0, retained: false)
            .sink { _ in }
            .store(in: &cancellables)
        
        mqttRepository.publish(topic: "traffic/status/yellow", message: state.yellowOn ? "ON" : "OFF", qos: .qos0, retained: false)
            .sink { _ in }
            .store(in: &cancellables)
        
        mqttRepository.publish(topic: "traffic/status/green", message: state.greenOn ? "ON" : "OFF", qos: .qos0, retained: false)
            .sink { _ in }
            .store(in: &cancellables)
        
        mqttRepository.publish(topic: "traffic/status/mode", message: state.mode, qos: .qos0, retained: false)
            .sink { _ in }
            .store(in: &cancellables)
        
        let lightsStatus = [
            "red": state.redOn,
            "yellow": state.yellowOn,
            "green": state.greenOn
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: lightsStatus),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            mqttRepository.publish(topic: "traffic/status/lights", message: jsonString, qos: .qos0, retained: false)
                .sink { _ in }
                .store(in: &cancellables)
        }
        
        let systemStatus = [
            "mode": state.mode,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "uptime": Int(state.uptime),
            "simulator": "swift-macos"
        ] as [String : Any]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: systemStatus),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            mqttRepository.publish(topic: "traffic/status/system", message: jsonString, qos: .qos0, retained: false)
                .sink { _ in }
                .store(in: &cancellables)
        }
    }
    
    private func startStatusPublishing() {
        statusTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.publishStatus()
        }
    }
    
    private func handleMQTTMessage(topic: String, payload: String) {
        state.addLog("Received: \(topic) = \(payload)", type: .mqtt)
        
        switch topic {
        case "traffic/mode":
            setMode(payload)
            
        case "traffic/red":
            if state.mode == "MANUAL" {
                state.redOn = (payload == "ON")
                state.addLog("🔴 Red light: \(payload)", type: payload == "ON" ? .error : .info)
                publishStatus()
            }
            
        case "traffic/yellow":
            if state.mode == "MANUAL" {
                state.yellowOn = (payload == "ON")
                state.addLog("🟡 Yellow light: \(payload)", type: payload == "ON" ? .warning : .info)
                publishStatus()
            }
            
        case "traffic/green":
            if state.mode == "MANUAL" {
                state.greenOn = (payload == "ON")
                state.addLog("🟢 Green light: \(payload)", type: payload == "ON" ? .success : .info)
                publishStatus()
            }
            
        case "traffic/timing/red":
            if let duration = Int(payload) {
                state.redDuration = duration
                state.addLog("Set red duration to \(duration)s", type: .info)
            }
            
        case "traffic/timing/yellow":
            if let duration = Int(payload) {
                state.yellowDuration = duration
                state.addLog("Set yellow duration to \(duration)s", type: .info)
            }
            
        case "traffic/timing/green":
            if let duration = Int(payload) {
                state.greenDuration = duration
                state.addLog("Set green duration to \(duration)s", type: .info)
            }
            
        case "traffic/flash/color":
            state.flashColor = payload
            state.addLog("Set flash color to \(payload)", type: .warning)
            if state.mode == "FLASHING" {
                startFlashing()
            }
            
        case "traffic/flash/interval":
            if let interval = Int(payload) {
                state.flashInterval = interval
                state.addLog("Set flash interval to \(interval)ms", type: .warning)
                if state.mode == "FLASHING" {
                    startFlashing()
                }
            }
            
        default:
            break
        }
    }
}