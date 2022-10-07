//
//  StateManagementTests.swift
//  StateManagementTests
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import ComposableArchitecture
import XCTest
@testable import Counter
@testable import FavoritesPrimes
@testable import PrimeModal
@testable import StateManagement

class StateManagementTests: XCTestCase {
    
    func testIntegration() {
        var fileClient = FileClient.mock
        fileClient.load = { _ in
            return Effect<Data?>.sync {
                try! JSONEncoder().encode([2, 31, 7])
            }
        }
        
        assert(initialValue: AppState(),
               reducer: appReducer,
               environment: (fileClient: fileClient, nthPrime: { _ in .sync { 17 } }),
               steps:
                Step(.send, .counterView(.counter(.nthPrimeButtonTapped)), {
            $0.isNthPrimeButtonDisabled = true
        }),
               Step(.receive, .counterView(.counter(CounterAction.nthPrimeResponse(17))), {
            $0.isNthPrimeButtonDisabled = false
            $0.alertNthPrime = PrimeAlert(prime: 17)
        }),
               Step(.send, .counterView(.counter(.alertDismissButtonTapped))) {
            $0.alertNthPrime = nil
        },
               Step(.send, .favoritesPrimes(.loadButtonTapped)),
               Step(.receive, .favoritesPrimes(.loadedFavoritePrimes([2, 31, 7]))) {
            $0.favoritesPrimes = [2, 31, 7]
        }
        )
    }
    
}
