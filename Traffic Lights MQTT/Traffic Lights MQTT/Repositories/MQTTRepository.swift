//
//  MQTTRepository.swift
//  Traffic Lights MQTT
//
//  Repository for MQTT data access operations
//

import Foundation
import CocoaMQTT
import Combine

protocol MQTTRepositoryProtocol {
    func connect(host: String, port: UInt16, username: String, password: String) -> AnyPublisher<Bool, Never>
    func disconnect()
    func publish(topic: String, message: String) -> AnyPublisher<Bool, Never>
    func subscribeToStatusUpdates() -> AnyPublisher<(String, String), Never>
    var connectionStatus: AnyPublisher<String, Never> { get }
    var isConnected: AnyPublisher<Bool, Never> { get }
}

class MQTTRepository: NSObject, MQTTRepositoryProtocol {
    
    private var mqtt: CocoaMQTT?
    private let clientID = "ios_traffic_\(UUID().uuidString)"
    
    private let connectionStatusSubject = CurrentValueSubject<String, Never>("Disconnected")
    private let isConnectedSubject = CurrentValueSubject<Bool, Never>(false)
    private let messageReceivedSubject = PassthroughSubject<(String, String), Never>()
    private let publishResultSubject = PassthroughSubject<Bool, Never>()
    
    var connectionStatus: AnyPublisher<String, Never> {
        connectionStatusSubject.eraseToAnyPublisher()
    }
    
    var isConnected: AnyPublisher<Bool, Never> {
        isConnectedSubject.eraseToAnyPublisher()
    }
    
    func connect(host: String, port: UInt16, username: String, password: String) -> AnyPublisher<Bool, Never> {
        mqtt = CocoaMQTT(clientID: clientID, host: host, port: port)
        mqtt?.username = username
        mqtt?.password = password
        mqtt?.keepAlive = 60
        mqtt?.delegate = self
        
        guard let mqtt = mqtt else {
            return Just(false).eraseToAnyPublisher()
        }
        
        _ = mqtt.connect()
        
        return isConnected
            .filter { $0 }
            .first()
            .eraseToAnyPublisher()
    }
    
    func disconnect() {
        mqtt?.disconnect()
        isConnectedSubject.value = false
    }
    
    func publish(topic: String, message: String) -> AnyPublisher<Bool, Never> {
        guard let mqtt = mqtt, isConnectedSubject.value else {
            return Just(false).eraseToAnyPublisher()
        }
        
        mqtt.publish(topic, withString: message, qos: .qos1)
        return Just(true).eraseToAnyPublisher()
    }
    
    func subscribeToStatusUpdates() -> AnyPublisher<(String, String), Never> {
        return messageReceivedSubject.eraseToAnyPublisher()
    }
}

extension MQTTRepository: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        DispatchQueue.main.async {
            let isConnected = ack == .accept
            self.connectionStatusSubject.value = isConnected ? "Connected" : "Connection Failed"
            self.isConnectedSubject.value = isConnected
        }
        
        if ack == .accept {
            mqtt.subscribe("traffic/status/+", qos: .qos1)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        let topic = message.topic
        let payload = message.string ?? ""
        
        DispatchQueue.main.async {
            self.messageReceivedSubject.send((topic, payload))
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        DispatchQueue.main.async {
            self.publishResultSubject.send(true)
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {}
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {}
    func mqttDidPing(_ mqtt: CocoaMQTT) {}
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        DispatchQueue.main.async {
            self.connectionStatusSubject.value = "Disconnected"
            self.isConnectedSubject.value = false
        }
    }
}