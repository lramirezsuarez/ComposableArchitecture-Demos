//
//  CounterTests.swift
//  CounterTests
//
//  Created by Luis Alejandro Ramirez Suarez on 29/08/22.
//

import XCTest
@testable import Counter

class CounterTests: XCTestCase {
    
    func testIncrDecrButtonTapped() {
        assert(
            initialValue: CounterViewState(count: 2),
            reducer: counterViewReducer,
            environment: { _ in .sync { 17 }},
            steps:
                Step(.send, .counter(.incrementTap)) { $0.count = 3 },
            Step(.send, .counter(.incrementTap)) { $0.count = 4 },
            Step(.send, .counter(.decrementTap)) { $0.count = 3 }
        )
    }
    
    func testNthPrimeButtonHappyFlow() {
        
        assert(
            initialValue: CounterViewState(
                alertNthPrime: nil,
                isNthPrimeButtonDisabled: false
            ),
            reducer: counterViewReducer,
            environment: { _ in .sync { 17 }},
            steps:
                Step(.send, .counter(.nthPrimeButtonTapped)) {
                    $0.isNthPrimeButtonDisabled = true
                },
            Step(.receive, .counter(.nthPrimeResponse(17))) {
                $0.alertNthPrime = PrimeAlert(n: 1, prime: 17)
                $0.isNthPrimeButtonDisabled = false
            },
            Step(.send, .counter(.alertDismissButtonTapped)) {
                $0.alertNthPrime = nil
            }
        )
    }
    
    func testNthPrimeButtonUnhappyFlow() {
        assert(
            initialValue: CounterViewState(
                alertNthPrime: nil,
                isNthPrimeButtonDisabled: false
            ),
            reducer: counterViewReducer,
            environment: { _ in .sync { nil }},
            steps:
                Step(.send, .counter(.nthPrimeButtonTapped)) {
                    $0.isNthPrimeButtonDisabled = true
                },
            Step(.receive, .counter(.nthPrimeResponse(nil))) {
                $0.isNthPrimeButtonDisabled = false
            }
        )
    }
    
    func testPrimeModal() {
        assert(
            initialValue: CounterViewState(
                count: 1,
                favoritePrimes: [3, 5]
            ),
            reducer: counterViewReducer,
            environment: { _ in .sync { nil }},
            steps:
                Step(.send, .counter(.incrementTap), { $0.count = 2 }),
                Step(.send, .primeModal(.saveFavoritePrimeTapped)) {
                    $0.favoritePrimes = [3, 5, 2]
                },
            Step(.send, .primeModal(.removeFavoritePrimeTapped)) {
                $0.favoritePrimes = [3, 5]
            }
        )
    }
}
