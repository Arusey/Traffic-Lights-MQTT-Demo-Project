# Traffic Light MQTT Control System

A distributed traffic light control system consisting of an iOS controller app and a macOS Arduino simulator, communicating via MQTT protocol over a remote Docker-based broker.

## What it does

This project simulates a real-world traffic light system where:
- **iOS App**: Acts as a remote control interface to manage traffic light states and modes
- **macOS Simulator**: Simulates an Arduino-based traffic light controller that responds to MQTT commands
- **MQTT Broker**: A secure, Docker-containerized Mosquitto broker running on a VPS that enables real-time communication between the apps over the internet

The broker is deployed using Docker Compose with:
- **Mosquitto MQTT Broker**: Eclipse Mosquitto running in a Docker container
- **User Authentication**: Password-protected access with configurable user accounts
- **Persistence**: Message and subscription persistence across restarts

The system supports multiple modes:
- **Manual Mode**: Direct control of individual lights (red, yellow, green)
- **Auto Mode**: Automatic cycling through traffic light sequences with configurable timing
- **Off Mode**: Turning off all the lights

## Setup Instructions

### Prerequisites
- Xcode 14+ 
- iOS 15+ device or simulator
- macOS 12+ for the simulator app

### 1. Configure MQTT Connection

In each Project there is a `mqtt-config.json` file in the project root:

```json
{
  "host": "YOUR_MQTT_BROKER_IP",
  "port": 1883,
  "username": "your_username",
  "password": "your_password"
}
```

**Important**: The json file contents will be shared separately since the repo is public
**Replace these values with the IP address and credentials shared via Email for the connection to the broker.**

### 2. iOS App Setup

1. Open `Traffic Lights MQTT.xcodeproj` in Xcode
2. Add `mqtt-config.json` to the iOS app bundle:
   - Update the broker IP address and credentials shared
3. Build and run on your iOS device/simulator

### 3. macOS Simulator Setup

1. Open `Traffic Lights MQTT Simulator.xcodeproj` in Xcode
2. Add `mqtt-config.json` to the macOS app bundle:
   - Update the broker IP address and credentials shared
3. Build and run the macOS simulator

### 4. Usage

1. **Start the macOS simulator** and click "Connect to MQTT"
2. **Open the iOS app** and connect to MQTT
3. **Control the traffic light** from the iOS app:
   - Switch between Auto/Manual modes
   - In Manual mode, tap individual lights to toggle them
   - Adjust timing settings for Auto mode
4. **Monitor activity** in the macOS simulator logs


## MQTT Topics

The system uses these MQTT topics for communication:

**Commands (iOS → Simulator):**
- `traffic/mode` - Set mode (AUTO, MANUAL, OFF)
- `traffic/red` - Manual red light control (ON/OFF)
- `traffic/yellow` - Manual yellow light control (ON/OFF)  
- `traffic/green` - Manual green light control (ON/OFF)
- `traffic/timing/red` - Set red light duration (seconds)
- `traffic/timing/yellow` - Set yellow light duration (seconds)
- `traffic/timing/green` - Set green light duration (seconds)

**Status (Simulator → iOS):**
- `traffic/status/lights` - Current light states (JSON)
- `traffic/status/mode` - Current operating mode
- `traffic/status/system` - System status and uptime

## Dependencies

- **CocoaMQTT**: Swift MQTT client library for iOS/macOS communication
- **SwiftUI**: Modern UI framework for both apps

## MQTT Broker Details

The project uses a self-hosted Mosquitto MQTT broker deployed on a VPS using Docker. Key features:

- **Containerized Deployment**: Easy setup and maintenance using Docker Compose
- **Authentication**: User-based access control
- **Monitoring**: Built-in logging

This project is a demonstration of how MQTT protocol is used to communicate between devices. A demo video has also been attached to the Repo.
