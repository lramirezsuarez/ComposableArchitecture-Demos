//
//  Counter.swift
//  Counter
//
//  Created by Luis Alejandro Ramirez Suarez on 29/08/22.
//

import ComposableArchitecture
import PrimeModal

public typealias CounterViewState = (count: Int, favoritesPrimes: [Int])

public enum CounterViewAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    
    var counter: CounterAction? {
        get {
            guard case let .counter(value) = self else { return nil }
            return value
        }
        set {
            guard case .counter = self, let newValue = newValue else { return }
            self = .counter(newValue)
        }
    }
    
    var primeModal: PrimeModalAction? {
        get {
            guard case let .primeModal(value) = self else { return nil }
            return value
        }
        set {
            guard case .primeModal = self, let newValue = newValue else { return }
            self = .primeModal(newValue)
        }
    }
}

public enum CounterAction {
    case decrementTap
    case incrementTap
}


public func counterReducer(state: inout Int, action: CounterAction) {
    switch action {
    case .decrementTap:
        state -= 1
    case .incrementTap:
        state += 1
    }
}

public let counterViewReducer = combine(
    pullback(counterReducer, value: \CounterViewState.count, action: \CounterViewAction.counter),
    pullback(primeModalReducer, value: \.self, action: \.primeModal)
)
