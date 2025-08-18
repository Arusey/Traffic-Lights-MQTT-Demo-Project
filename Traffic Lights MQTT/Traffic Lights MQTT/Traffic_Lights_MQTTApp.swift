//
//  Traffic_Lights_MQTTApp.swift
//  Traffic Lights MQTT
//
//  Created by Kevin Lagat Home PC on 17/08/2025.
//

import SwiftUI

@main
struct Traffic_Lights_MQTTApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TrafficsLightsHomePage()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
