//
//  FavoritesPrimesTests.swift
//  FavoritesPrimesTests
//
//  Created by Luis Alejandro Ramirez Suarez on 29/08/22.
//

import XCTest
@testable import FavoritesPrimes

class FavoritesPrimesTests: XCTestCase {
    func testDeleteFavoritePrimes() {
        var state = [2, 3, 5, 7]
        let effects = favoritePrimesReducer(state: &state, action: .deleteFavoritePrimes([2]))
        
        XCTAssertEqual(state, [2, 3, 7])
        XCTAssert(effects.isEmpty)
    }
    
    func testSaveButtonTapped() {
        var state = [2, 3, 5, 7]
        let effects = favoritePrimesReducer(state: &state, action: .saveButtonTapped)
        
        XCTAssertEqual(state, [2, 3, 5, 7])
        XCTAssertEqual(effects.count, 1)
    }
    
    func testLoadButtonTapped() {
        var state = [2, 3, 5, 7]
        var effects = favoritePrimesReducer(state: &state, action: .loadButtonTapped)
        
        XCTAssertEqual(state, [2, 3, 5, 7])
        XCTAssertEqual(effects.count, 1)
        
        effects = favoritePrimesReducer(state: &state, action: .loadedFavoritePrimes([2, 31]))
        XCTAssertEqual(state, [2, 31])
        XCTAssert(effects.isEmpty)
    }
}
