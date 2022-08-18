//
//  StateManagementApp.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI

@main
struct StateManagementApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(state: .init())
        }
    }
}
