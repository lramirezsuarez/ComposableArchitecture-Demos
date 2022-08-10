//
//  ComposableArchitecture_ToDoApp.swift
//  ComposableArchitecture-ToDo
//
//  Created by Luis Alejandro Ramirez Suarez on 9/08/22.
//

import SwiftUI
import ComposableArchitecture

@main
struct ComposableArchitecture_ToDoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(
                initialState: AppState(todos: [
                    Todo(description: "Milk", id: UUID(), isComplete: false),
                    Todo(description: "Eggs", id: UUID(), isComplete: false),
                    Todo(description: "Hand Soap", id: UUID(), isComplete: true)
                ]),
                reducer: appReducer,
                environment: AppEnvironment()))
        }
    }
}
