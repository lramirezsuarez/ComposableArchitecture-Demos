//
//  CounterTests.swift
//  CounterTests
//
//  Created by Luis Alejandro Ramirez Suarez on 29/08/22.
//

import XCTest
import ComposableArchitecture
@testable import Counter

class CounterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Current = .mock
    }

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
        Current.nthPrime = { _ in .sync { 17 } }
        var state = CounterViewState(alertNthPrime: nil, count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: false)
        
        var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
        
        XCTAssertEqual(state, CounterViewState(alertNthPrime: nil, count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: true))
        XCTAssertEqual(effects.count, 1)
        
        var nextAction: CounterViewAction!
        let receivedCompletion = self.expectation(description: "receiveCompletion")
        _ = effects[0].sink(
            receiveCompletion: { _ in receivedCompletion.fulfill() },
            receiveValue: { action in
                nextAction = action
                XCTAssertEqual(action, .counter(.nthPrimeResponse(17)))
            })
        self.wait(for: [receivedCompletion], timeout: 0.1)
        
        effects = counterViewReducer(&state, nextAction)
        
        XCTAssertEqual(state, CounterViewState(alertNthPrime: PrimeAlert(prime: 3), count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: false))
        XCTAssert(effects.isEmpty)
        
        effects = counterViewReducer(&state, .counter(.alertDismissButtonTapped))
        
        XCTAssertEqual(state, CounterViewState(alertNthPrime: nil, count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: false))
        XCTAssert(effects.isEmpty)
    }
    
    func testNthPrimeButtonUnhappyFlow() {
        Current.nthPrime = { _ in .sync { nil } }
        var state = CounterViewState(alertNthPrime: nil, count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: false)
        
        var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
        
        XCTAssertEqual(state, CounterViewState(alertNthPrime: nil, count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: true))
        XCTAssertEqual(effects.count, 1)
        
        effects = counterViewReducer(&state, .counter(.nthPrimeResponse(nil)))
        
        XCTAssertEqual(state, CounterViewState(alertNthPrime: nil, count: 2, favoritePrimes: [3, 5], isNthPrimeButtonDisabled: false))
        XCTAssert(effects.isEmpty)
    }
    
    func testNthPrimeButtonUnhappyFlow2() {
        Current.nthPrime = { _ in .sync { nil } }
        var state = CounterViewState(
            alertNthPrime: nil,
            count: 7,
            favoritePrimes: [2, 3],
            isNthPrimeButtonDisabled: false
        )
        
        var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
        XCTAssertEqual(
            state,
            CounterViewState(
                alertNthPrime: nil,
                count: 7,
                favoritePrimes: [2, 3],
                isNthPrimeButtonDisabled: true
            )
        )
        XCTAssertEqual(effects.count, 1)
        
        let receivedCompletion = self.expectation(description: "receivedCompletion")
        var nextAction: CounterViewAction!
        _ = effects[0].sink(
            receiveCompletion: { _ in
                receivedCompletion.fulfill()
            },
            receiveValue: { action in
                nextAction = action
                XCTAssertEqual(action, .counter(.nthPrimeResponse(nil)))
            })
        self.wait(for: [receivedCompletion], timeout: 0.1)
        
        effects = counterViewReducer(&state, nextAction)
        XCTAssertEqual(
            state,
            CounterViewState(
                alertNthPrime: nil,
                count: 7,
                favoritePrimes: [2, 3],
                isNthPrimeButtonDisabled: false
            )
        )
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
