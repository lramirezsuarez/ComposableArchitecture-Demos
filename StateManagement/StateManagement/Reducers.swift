//
//  Reducers.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 24/08/22.
//

import Foundation

func counterReducer(state: inout Int, action: CounterAction) {
    switch action {
    case .decrementTap:
        state -= 1
    case .incrementTap:
        state += 1
    }
}

func primeModalReducer(state: inout AppState, action: PrimeModalAction) {
    switch action {
    case .removeFavoritePrimeTapped:
        state.favoritesPrimes.removeAll(where: { $0 == state.count })
        state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
    case .saveFavoritePrimeTapped:
        state.favoritesPrimes.append(state.count)
        state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
    }
}

struct FavoritePrimeState {
    var favoritesPrimes: [Int]
    var activityFeed: [AppState.Activity]
}

func favoritePrimesReducer(state: inout FavoritePrimeState, action: FavoritePrimesAction) {
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        for index in indexSet {
            let prime = state.favoritesPrimes[index]
            state.favoritesPrimes.remove(at: index)
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
        }
    }
}

extension AppState {
    var favoritesPrimeState: FavoritePrimeState {
        get {
            FavoritePrimeState(favoritesPrimes: self.favoritesPrimes, activityFeed: self.activityFeed)
        }
        set {
            self.favoritesPrimes = newValue.favoritesPrimes
            self.activityFeed = newValue.activityFeed
        }
    }
}


let _appReducer: (inout AppState, AppAction) -> Void = combine(
    pullback(counterReducer, value: \.count, action: \.counter),
    pullback(primeModalReducer, value: \.self, action: \.primeModal),
    pullback(favoritePrimesReducer, value: \.favoritesPrimeState, action: \.favoritesPrimes)
)

let appReducer = pullback(_appReducer, value: \.self, action: \.self)

func combine<Value, Action>(
    _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {
    
    return { value, action in
        for reducer in reducers {
            reducer(&value, action)
        }
    }
}

func pullback<GlobalValue, LocalValue, GlobalAction, LocalAction>(
    _ reducer: @escaping (inout LocalValue, LocalAction) -> Void,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> (inout GlobalValue, GlobalAction) -> Void {
    
    return { globalValue, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return }
        reducer(&globalValue[keyPath: value], localAction)
    }
}
