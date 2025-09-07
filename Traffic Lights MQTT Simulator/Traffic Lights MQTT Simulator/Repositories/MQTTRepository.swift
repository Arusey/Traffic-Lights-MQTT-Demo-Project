//
//  MQTTRepository.swift
//  Traffic Lights MQTT Simulator
//
//  Repository for MQTT data access operations
//

import Foundation
import CocoaMQTT
import Combine

protocol MQTTRepositoryProtocol {
    func connect(host: String, port: UInt16, username: String, password: String) -> AnyPublisher<Bool, Never>
    func disconnect()
    func publish(topic: String, message: String, qos: CocoaMQTTQoS, retained: Bool) -> AnyPublisher<Bool, Never>
    func subscribeToTopics(_ topics: [String]) -> AnyPublisher<Bool, Never>
    func messageReceived() -> AnyPublisher<(String, String), Never>
    var connectionStatus: AnyPublisher<String, Never> { get }
    var isConnected: AnyPublisher<Bool, Never> { get }
}

class MQTTRepository: NSObject, MQTTRepositoryProtocol {
    
    private var mqtt: CocoaMQTT?
    private let clientID = "swift_arduino_simulator"
    
    private let connectionStatusSubject = CurrentValueSubject<String, Never>("Disconnected")
    private let isConnectedSubject = CurrentValueSubject<Bool, Never>(false)
    private let messageReceivedSubject = PassthroughSubject<(String, String), Never>()
    private let publishResultSubject = PassthroughSubject<Bool, Never>()
    private let subscribeResultSubject = PassthroughSubject<Bool, Never>()
    
    var connectionStatus: AnyPublisher<String, Never> {
        connectionStatusSubject.eraseToAnyPublisher()
    }
    
    var isConnected: AnyPublisher<Bool, Never> {
        isConnectedSubject.eraseToAnyPublisher()
    }
    
    func connect(host: String, port: UInt16, username: String, password: String) -> AnyPublisher<Bool, Never> {
        if let existingMqtt = mqtt {
            existingMqtt.disconnect()
            mqtt = nil
        }
        
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
            return Just(false).eraseToAnyPublisher()
        }
        
        _ = mqtt.connect(timeout: 10)
        
        return isConnected
            .filter { $0 }
            .first()
            .timeout(.seconds(15), scheduler: DispatchQueue.main)
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    func disconnect() {
        mqtt?.disconnect()
        isConnectedSubject.value = false
    }
    
    func publish(topic: String, message: String, qos: CocoaMQTTQoS = .qos0, retained: Bool = false) -> AnyPublisher<Bool, Never> {
        guard let mqtt = mqtt, isConnectedSubject.value else {
            return Just(false).eraseToAnyPublisher()
        }
        
        mqtt.publish(topic, withString: message, qos: qos, retained: retained)
        return Just(true).eraseToAnyPublisher()
    }
    
    func subscribeToTopics(_ topics: [String]) -> AnyPublisher<Bool, Never> {
        guard let mqtt = mqtt, isConnectedSubject.value else {
            return Just(false).eraseToAnyPublisher()
        }
        
        for topic in topics {
            mqtt.subscribe(topic, qos: .qos1)
        }
        return Just(true).eraseToAnyPublisher()
    }
    
    func messageReceived() -> AnyPublisher<(String, String), Never> {
        return messageReceivedSubject.eraseToAnyPublisher()
    }
}

extension MQTTRepository: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        DispatchQueue.main.async {
            if ack == .accept {
                self.connectionStatusSubject.value = "Connected"
                self.isConnectedSubject.value = true
                
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
                }
                
                mqtt.publish("traffic/status/connection", withString: "ONLINE", qos: .qos0, retained: true)
                
            } else {
                self.connectionStatusSubject.value = "Connection Failed"
                self.isConnectedSubject.value = false
            }
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