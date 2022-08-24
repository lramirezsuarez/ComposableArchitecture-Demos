//
//  Reducers.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 24/08/22.
//

import Foundation

func counterReducer(state: inout Int, action: AppAction) {
    switch action {
    case .counter(.decrementTap):
        state -= 1
    case .counter(.incrementTap):
        state += 1
    default:
        break
    }
}

func primeModalReducer(state: inout AppState, action: AppAction) {
    switch action {
    case .primeModal(.removeFavoritePrimeTapped):
        state.favoritesPrimes.removeAll(where: { $0 == state.count })
        state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
    case .primeModal(.saveFavoritePrimeTapped):
        state.favoritesPrimes.append(state.count)
        state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
    default:
        break
    }
}

struct FavoritePrimeState {
    var favoritesPrimes: [Int]
    var activityFeed: [AppState.Activity]
}

func favoritePrimesReducer(state: inout FavoritePrimeState, action: AppAction) {
    switch action {
    case let .favoritesPrimes(.deleteFavoritePrimes(indexSet)):
        for index in indexSet {
            let prime = state.favoritesPrimes[index]
            state.favoritesPrimes.remove(at: index)
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
        }
    default:
        break
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


let _appReducer = combine(pullback(counterReducer, value: \.count),
                         primeModalReducer,
                          pullback(favoritePrimesReducer, value: \.favoritesPrimeState))

let appReducer = pullback(_appReducer, value: \.self)

func combine<Value, Action>(
    _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {
    
    return { value, action in
        for reducer in reducers {
            reducer(&value, action)
        }
    }
}

func pullback<LocalValue, GlobalValue, Action>(
    _ reducer: @escaping (inout LocalValue, Action) -> Void,
    value: WritableKeyPath<GlobalValue, LocalValue>
) -> (inout GlobalValue, Action) -> Void {
    return { globalValue, action in
        reducer(&globalValue[keyPath: value], action)
    }
}
