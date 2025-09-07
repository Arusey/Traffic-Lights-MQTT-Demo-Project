//
//  ConfigurationRepository.swift
//  Traffic Lights MQTT
//
//  Repository for configuration data access
//

import Foundation

protocol ConfigurationRepositoryProtocol {
    func loadMQTTConfiguration() -> MQTTConfiguration?
}

struct MQTTConfiguration {
    let host: String
    let port: UInt16
    let username: String
    let password: String
}

class ConfigurationRepository: ConfigurationRepositoryProtocol {
    
    func loadMQTTConfiguration() -> MQTTConfiguration? {
        guard let url = Bundle.main.url(forResource: "mqtt-config", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let config = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("Failed to load MQTT config, using defaults")
            return MQTTConfiguration(
                host: "localhost",
                port: 1883,
                username: "",
                password: ""
            )
        }
        
        return MQTTConfiguration(
            host: config["host"] as? String ?? "localhost",
            port: UInt16(config["port"] as? Int ?? 1883),
            username: config["username"] as? String ?? "",
            password: config["password"] as? String ?? ""
        )
    }
}