//
//  StateManagementApp.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI
import Overture
import ComposableArchitecture
import Counter

@main
struct StateManagementApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: .init(
                    initialValue: .init(),
                    reducer: appReducer
                        .activityFeed()
                        .logging(),
//                    reducer: with(
//                        appReducer,
//                        compose(
//                            logging,
//                            activityFeed
//                        )
//                    ),
                    environment: AppEnvironment(fileClient: .live, nthPrime: Counter.nthPrime, offlineNthPrime: Counter.offlineNthPrime)
                )
            )
        }
    }
}
