//
//  DependencyContainer.swift
//  Traffic Lights MQTT Simulator
//
//  Dependency injection container for shared services
//

import Foundation

class DependencyContainer {
    static let shared = DependencyContainer()
    
    lazy var mqttRepository: MQTTRepositoryProtocol = MQTTRepository()
    lazy var configRepository: ConfigurationRepositoryProtocol = ConfigurationRepository()
    
    private init() {}
    
    func makeSimulatorViewModel() -> SimulatorViewModel {
        return SimulatorViewModel(
            mqttRepository: mqttRepository,
            configRepository: configRepository
        )
    }
}