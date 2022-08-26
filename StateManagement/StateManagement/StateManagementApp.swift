//
//  StateManagementApp.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI
import Overture

@main
struct StateManagementApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: .init(
                    initialValue: .init(),
                    reducer: with(
                        appReducer,
                        compose(
                            logging,
                            activityFeed
                        )
                    )
                )
            )
        }
    }
}
