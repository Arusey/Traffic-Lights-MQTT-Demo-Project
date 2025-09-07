//
//  DependencyContainer.swift
//  Traffic Lights MQTT
//
//  Dependency injection container for shared services
//

import Foundation

class DependencyContainer {
    static let shared = DependencyContainer()
    
    lazy var mqttRepository: MQTTRepositoryProtocol = MQTTRepository()
    lazy var configRepository: ConfigurationRepositoryProtocol = ConfigurationRepository()
    
    private init() {}
    
    func makeTrafficLightViewModel() -> TrafficLightViewModel {
        return TrafficLightViewModel(
            mqttRepository: mqttRepository,
            configRepository: configRepository
        )
    }
    
    func makeMonitoringViewModel() -> MonitoringViewModel {
        return MonitoringViewModel(mqttRepository: mqttRepository)
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(
            configRepository: configRepository,
            mqttRepository: mqttRepository
        )
    }
}