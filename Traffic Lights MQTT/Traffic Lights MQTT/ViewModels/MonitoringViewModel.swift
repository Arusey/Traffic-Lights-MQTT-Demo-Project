//
//  MonitoringViewModel.swift
//  Traffic Lights MQTT
//
//  ViewModel for monitoring MQTT messages
//

import Foundation
import Combine

class MonitoringViewModel: ObservableObject {
    @Published var receivedMessages: [MQTTMessage] = []
    @Published var connectionStatus: String = "Disconnected"
    @Published var isConnected = false
    
    private let mqttRepository: MQTTRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private let maxMessages = 50
    
    init(mqttRepository: MQTTRepositoryProtocol = MQTTRepository()) {
        self.mqttRepository = mqttRepository
        setupBindings()
        setupOutgoingMessageListener()
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
                self?.addIncomingMessage(topic: topic, payload: payload)
            }
            .store(in: &cancellables)
    }
    
    private func setupOutgoingMessageListener() {
        NotificationCenter.default.publisher(for: NSNotification.Name("MQTTMessageSent"))
            .sink { [weak self] notification in
                if let userInfo = notification.userInfo,
                   let topic = userInfo["topic"] as? String,
                   let payload = userInfo["payload"] as? String {
                    self?.addOutgoingMessage(topic: topic, payload: payload)
                }
            }
            .store(in: &cancellables)
    }
    
    func addOutgoingMessage(topic: String, payload: String) {
        let message = MQTTMessage(
            topic: topic,
            payload: payload,
            timestamp: Date(),
            isOutgoing: true
        )
        addMessage(message)
    }
    
    private func addIncomingMessage(topic: String, payload: String) {
        let message = MQTTMessage(
            topic: topic,
            payload: payload,
            timestamp: Date(),
            isOutgoing: false
        )
        addMessage(message)
    }
    
    private func addMessage(_ message: MQTTMessage) {
        receivedMessages.insert(message, at: 0)
        
        if receivedMessages.count > maxMessages {
            receivedMessages.removeLast()
        }
    }
    
    func clearMessages() {
        receivedMessages.removeAll()
    }
    
    func exportMessages() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        
        return receivedMessages
            .sorted { $0.timestamp < $1.timestamp }
            .map { message in
                let direction = message.isOutgoing ? "OUT" : "IN"
                let timestamp = formatter.string(from: message.timestamp)
                return "[\(timestamp)] \(direction) - \(message.topic): \(message.payload)"
            }
            .joined(separator: "\n")
    }
}