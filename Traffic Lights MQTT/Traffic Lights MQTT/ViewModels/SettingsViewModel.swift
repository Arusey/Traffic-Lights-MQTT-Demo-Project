//
//  SettingsViewModel.swift
//  Traffic Lights MQTT
//
//  ViewModel for application settings
//

import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var mqttHost: String = "localhost"
    @Published var mqttPort: String = "1883"
    @Published var mqttUsername: String = ""
    @Published var mqttPassword: String = ""
    @Published var connectionStatus: String = "Disconnected"
    @Published var isConnected = false
    
    private let configRepository: ConfigurationRepositoryProtocol
    private let mqttRepository: MQTTRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(configRepository: ConfigurationRepositoryProtocol = ConfigurationRepository(),
         mqttRepository: MQTTRepositoryProtocol = MQTTRepository()) {
        self.configRepository = configRepository
        self.mqttRepository = mqttRepository
        
        loadCurrentConfiguration()
        setupBindings()
    }
    
    private func setupBindings() {
        mqttRepository.connectionStatus
            .assign(to: \.connectionStatus, on: self)
            .store(in: &cancellables)
        
        mqttRepository.isConnected
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)
    }
    
    private func loadCurrentConfiguration() {
        if let config = configRepository.loadMQTTConfiguration() {
            mqttHost = config.host
            mqttPort = String(config.port)
            mqttUsername = config.username
            mqttPassword = config.password
        }
    }
    
    func testConnection() {
        guard let port = UInt16(mqttPort) else {
            connectionStatus = "Invalid Port"
            return
        }
        
        mqttRepository.connect(
            host: mqttHost,
            port: port,
            username: mqttUsername,
            password: mqttPassword
        )
        .sink { success in
            if !success {
                DispatchQueue.main.async {
                    self.connectionStatus = "Connection Failed"
                }
            }
        }
        .store(in: &cancellables)
    }
    
    func disconnect() {
        mqttRepository.disconnect()
    }
    
    func resetToDefaults() {
        mqttHost = "localhost"
        mqttPort = "1883"
        mqttUsername = ""
        mqttPassword = ""
    }
    
    func saveConfiguration() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let config: [String: Any] = [
            "host": mqttHost,
            "port": Int(mqttPort) ?? 1883,
            "username": mqttUsername,
            "password": mqttPassword
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: config)
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent("mqtt-config.json")
                try data.write(to: fileURL)
            }
        } catch {
            print("Failed to save configuration: \(error)")
        }
    }
    
    var isValidConfiguration: Bool {
        !mqttHost.isEmpty && !mqttPort.isEmpty && UInt16(mqttPort) != nil
    }
}