//
//  TrafficLightViewModel.swift
//  Traffic Lights MQTT
//
//  ViewModel for traffic light business logic
//

import Foundation
import Combine

class TrafficLightViewModel: ObservableObject {
    @Published var trafficLightState = TrafficLightState()
    @Published var connectionStatus: String = "Disconnected"
    @Published var isConnected = false
    
    private let mqttRepository: MQTTRepositoryProtocol
    private let configRepository: ConfigurationRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(mqttRepository: MQTTRepositoryProtocol = MQTTRepository(),
         configRepository: ConfigurationRepositoryProtocol = ConfigurationRepository()) {
        self.mqttRepository = mqttRepository
        self.configRepository = configRepository
        
        setupBindings()
    }
    
    private func setupBindings() {
        mqttRepository.connectionStatus
            .assign(to: \.connectionStatus, on: self)
            .store(in: &cancellables)
        
        mqttRepository.isConnected
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)
        
        mqttRepository.subscribeToStatusUpdates()
            .sink { [weak self] topic, payload in
                self?.handleStatusUpdate(topic: topic, payload: payload)
            }
            .store(in: &cancellables)
    }
    
    func connect() {
        guard let config = configRepository.loadMQTTConfiguration() else {
            connectionStatus = "Configuration Error"
            return
        }
        
        mqttRepository.connect(
            host: config.host,
            port: config.port,
            username: config.username,
            password: config.password
        )
        .sink { _ in }
        .store(in: &cancellables)
    }
    
    func disconnect() {
        mqttRepository.disconnect()
    }
    
    func setMode(_ mode: TrafficLightMode) {
        trafficLightState.mode = mode
        publishCommand(topic: "traffic/mode", message: mode.rawValue)
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
        
        publishCommand(topic: "traffic/\(color.rawValue.lowercased())", message: command)
    }
    
    func setTiming(red: Int? = nil, yellow: Int? = nil, green: Int? = nil) {
        if let red = red {
            trafficLightState.redDuration = red
            publishCommand(topic: "traffic/timing/red", message: "\(red)")
        }
        if let yellow = yellow {
            trafficLightState.yellowDuration = yellow
            publishCommand(topic: "traffic/timing/yellow", message: "\(yellow)")
        }
        if let green = green {
            trafficLightState.greenDuration = green
            publishCommand(topic: "traffic/timing/green", message: "\(green)")
        }
    }
    
    private func publishCommand(topic: String, message: String) {
        mqttRepository.publish(topic: topic, message: message)
            .sink { success in
                if !success {
                    print("Failed to publish message to topic: \(topic)")
                } else {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("MQTTMessageSent"),
                        object: nil,
                        userInfo: ["topic": topic, "payload": message]
                    )
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleStatusUpdate(topic: String, payload: String) {
        switch topic {
        case "traffic/status/mode":
            if let mode = TrafficLightMode(rawValue: payload) {
                trafficLightState.mode = mode
            }
        case "traffic/status/lights":
            if let data = payload.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Bool] {
                trafficLightState.redOn = json["red"] ?? false
                trafficLightState.yellowOn = json["yellow"] ?? false
                trafficLightState.greenOn = json["green"] ?? false
            }
        case "traffic/status/red":
            trafficLightState.redOn = (payload == "ON")
        case "traffic/status/yellow":
            trafficLightState.yellowOn = (payload == "ON")
        case "traffic/status/green":
            trafficLightState.greenOn = (payload == "ON")
        default:
            break
        }
        
        trafficLightState.lastUpdate = Date()
    }
}