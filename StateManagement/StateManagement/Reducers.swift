//
//  Reducers.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 24/08/22.
//

import ComposableArchitecture
import Counter
import Foundation
import FavoritesPrimes
import PrimeModal

func activityFeed(
    _ reducer: @escaping Reducer<AppState, AppAction>
) -> Reducer<AppState, AppAction> {
    return { state, action in
        switch action {
        case .counterView(.counter),
                .favoritesPrimes(.loadedFavoritePrimes),
                .favoritesPrimes(.saveButtonTapped),
                .favoritesPrimes(.loadButtonTapped):
            break
        case .counterView(.primeModal(.removeFavoritePrimeTapped)):
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
        case .counterView(.primeModal(.saveFavoritePrimeTapped)):
            state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
        case let .favoritesPrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                state.activityFeed.append(
                    .init(timestamp: Date(), type: .removedFavoritePrime(state.favoritesPrimes[index]))
                )
            }
        }
        return reducer(&state, action)
    }
}


let appReducer = combine(
    pullback(counterViewReducer, value: \AppState.counterView, action: \AppAction.counterView),
    pullback(favoritePrimesReducer, value: \.favoritesPrimes, action: \.favoritesPrimes)
)
