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
                initialState: AppState(todos: [Todo(description: "Text", id: UUID(), isComplete: false)]),
                reducer: appReducer,
                environment: AppEnvironment()))
        }
    }
}
