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
        Counter.Current = .mock
        FavoritesPrimes.Current = .mock
    }

}
