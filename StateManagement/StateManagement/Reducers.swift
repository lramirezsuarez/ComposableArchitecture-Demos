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

func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) {
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
    }
}


let _appReducer: (inout AppState, AppAction) -> Void = combine(
    pullback(counterReducer, value: \.count, action: \.counter),
    pullback(primeModalReducer, value: \.self, action: \.primeModal),
    pullback(favoritePrimesReducer, value: \.favoritesPrimes, action: \.favoritesPrimes)
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

func activityFeed(
    _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    return { state, action in
        switch action {
        case .counter:
            break
        case .primeModal(.removeFavoritePrimeTapped):
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
        case .primeModal(.saveFavoritePrimeTapped):
            state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
        case let .favoritesPrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                state.activityFeed.append(
                    .init(timestamp: Date(), type: .removedFavoritePrime(state.favoritesPrimes[index]))
                )
            }
        }
        reducer(&state, action)
    }
}

func logging(
    _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    return { value, action in
        reducer(&value, action)
        print("Action: \(action)")
        print("State: ")
        dump(value)
        print("----")
    }
}

