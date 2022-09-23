//
//  CounterTests.swift
//  CounterTests
//
//  Created by Luis Alejandro Ramirez Suarez on 29/08/22.
//

import XCTest
@testable import Counter

class CounterTests: XCTestCase {

    func testIncrementButtonTapped() {
        var state = CounterViewState(alertNthPrime: nil, count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: false)
        let effects = counterViewReducer(&state, .counter(.incrementTap))
        
        XCTAssertEqual(state, CounterViewState(alertNthPrime: nil, count: 3, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: false))
        XCTAssert(effects.isEmpty)
    }
    
    func testDecrementButtonTapped() {
        var state = CounterViewState(alertNthPrime: nil, count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: false)
        let effects = counterViewReducer(&state, .counter(.decrementTap))
        
        XCTAssertEqual(state, CounterViewState(alertNthPrime: nil, count: 1, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: false))
        XCTAssert(effects.isEmpty)
    }
    
    func testNthPrimeButtonFlow() {
        var state = CounterViewState(alertNthPrime: nil, count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: false)
        
        var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
        
        XCTAssertEqual(state, CounterViewState(alertNthPrime: nil, count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: true))
        XCTAssertEqual(effects.count, 1)
        
        effects = counterViewReducer(&state, .counter(.nthPrimeResponse(3)))
        
        XCTAssertEqual(state, CounterViewState(alertNthPrime: PrimeAlert(prime: 3), count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: false))
        XCTAssert(effects.isEmpty)
        
        effects = counterViewReducer(&state, .counter(.alertDismissButtonTapped))
        
        XCTAssertEqual(state, CounterViewState(alertNthPrime: nil, count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: false))
        XCTAssert(effects.isEmpty)
    }
    
    func testNthPrimeButtonUnhappyFlow() {
        var state = CounterViewState(alertNthPrime: nil, count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: false)
        
        var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
        
        XCTAssertEqual(state, CounterViewState(alertNthPrime: nil, count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: true))
        XCTAssertEqual(effects.count, 1)
        
        effects = counterViewReducer(&state, .counter(.nthPrimeResponse(nil)))
        
        XCTAssertEqual(state, CounterViewState(alertNthPrime: nil, count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: false))
        XCTAssert(effects.isEmpty)
    }

    func testPrimeModal() {
        var state = CounterViewState(
            alertNthPrime: nil,
            count: 2,
            favoritePrimes: [3, 5],
            isNthPrimeButtonDisabled: false
        )
        
        var effects = counterViewReducer(&state, .primeModal(.saveFavoritePrimeTapped))
        
        XCTAssertEqual(
            state,
            CounterViewState(
                alertNthPrime: nil,
                count: 2,
                favoritePrimes: [3, 5, 2],
                isNthPrimeButtonDisabled: false
            )
        )
        XCTAssert(effects.isEmpty)
        
        effects = counterViewReducer(&state, .primeModal(.removeFavoritePrimeTapped))
        
        XCTAssertEqual(
            state,
            CounterViewState(
                alertNthPrime: nil,
                count: 2,
                favoritePrimes: [3, 5],
                isNthPrimeButtonDisabled: false
            )
        )
        XCTAssert(effects.isEmpty)
    }
}
