//
//  PrimeModalTests.swift
//  PrimeModalTests
//
//  Created by Luis Alejandro Ramirez Suarez on 29/08/22.
//

import XCTest
@testable import PrimeModal

class PrimeModalTests: XCTestCase {

    func testSaveFavoritesPrimesTapped() {
        var state = (count: 2, favoritesPrimes: [3, 5])
        let effects = primeModalReducer(state: &state, action: .saveFavoritePrimeTapped)
        
        let (count, favoritesPrimes) = state
        XCTAssertEqual(count, 2)
        XCTAssertEqual(favoritesPrimes, [3, 5, 2])
        XCTAssert(effects.isEmpty)
    }
    
    func testRemoveFavoritesPrimesTapped() {
        var state = (count: 3, favoritesPrimes: [3, 5])
        let effects = primeModalReducer(state: &state, action: .removeFavoritePrimeTapped)
        
        let (count, favoritesPrimes) = state
        XCTAssertEqual(count, 3)
        XCTAssertEqual(favoritesPrimes, [5])
        XCTAssert(effects.isEmpty)
    }

}
