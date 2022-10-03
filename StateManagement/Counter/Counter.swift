//
//  Counter.swift
//  Counter
//
//  Created by Luis Alejandro Ramirez Suarez on 29/08/22.
//

import ComposableArchitecture
import PrimeModal

public struct CounterViewState: Equatable {
    public var alertNthPrime: PrimeAlert?
    public var count: Int
    public var favoritePrimes: [Int]
    public var isNthPrimeButtonDisabled: Bool
    
    public init(
        alertNthPrime: PrimeAlert? = nil,
        count: Int = 0,
        favoritePrimes: [Int] = [],
        isNthPrimeButtonDisabled: Bool = false
    ) {
        self.alertNthPrime = alertNthPrime
        self.count = count
        self.favoritePrimes = favoritePrimes
        self.isNthPrimeButtonDisabled = isNthPrimeButtonDisabled
    }
    
    var counter: CounterState {
        get { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled) }
        set { (self.alertNthPrime, self.count, self.isNthPrimeButtonDisabled) = newValue }
    }
    
    var primeModal: PrimeModalState {
        get { (self.count, self.favoritePrimes) }
        set { (self.count, self.favoritePrimes) = newValue }
    }
}


public enum CounterViewAction: Equatable {
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

public enum CounterAction: Equatable {
    case decrementTap
    case incrementTap
    case nthPrimeButtonTapped
    case nthPrimeResponse(Int?)
    case alertDismissButtonTapped
}

public typealias CounterState = (alertNthPrime: PrimeAlert?, count: Int, isNthPrimeButtonDisabled: Bool)

public func counterReducer(state: inout CounterState, action: CounterAction, environment: CounterEnvironment) -> [Effect<CounterAction>] {
    switch action {
    case .decrementTap:
        state.count -= 1
        return []
    case .incrementTap:
        state.count += 1
        return []
    case .nthPrimeButtonTapped:
        state.isNthPrimeButtonDisabled = true
        return [
//            nthPrime(state.count)
            environment(state.count)
                .map(CounterAction.nthPrimeResponse)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()]
        
    case let .nthPrimeResponse(prime):
        state.alertNthPrime = prime.map(PrimeAlert.init(prime:))
        state.isNthPrimeButtonDisabled = false
        return []
    case .alertDismissButtonTapped:
        state.alertNthPrime = nil
        return []
    }
}

//public struct CounterEnvironment {
//    var nthPrime: (Int) -> Effect<Int?>
//}
//
//extension CounterEnvironment {
//    public static let live = CounterEnvironment(nthPrime: Counter.nthPrime)
//}
public typealias CounterEnvironment = (Int) -> Effect<Int?>
//
//#if DEBUG
//let mock = { (Int) in Effect.sync { 17 }}
//#endif

public let counterViewReducer: Reducer<CounterViewState, CounterViewAction, CounterEnvironment> = combine(
    pullback(counterReducer, value: \CounterViewState.counter, action: \CounterViewAction.counter, environment: { $0 }),
    pullback(primeModalReducer, value: \.primeModal, action: \.primeModal, environment: { _ in () })
)
