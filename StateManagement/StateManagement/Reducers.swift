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
    _ reducer: @escaping Reducer<AppState, AppAction, AppEnvironment>
) -> Reducer<AppState, AppAction, AppEnvironment> {
    return { state, action, environment in
        switch action {
        case .counterView(.counter),
                .offlineCounterView(.counter),
                .favoritesPrimes(.loadedFavoritePrimes),
                .favoritesPrimes(.saveButtonTapped),
                .favoritesPrimes(.loadButtonTapped),
                .favoritesPrimes(.alertDimissButtonTapped),
                .favoritesPrimes(.nthPrimeResponse),
                .favoritesPrimes(.primeButtonTapped):
            break
        case .counterView(.primeModal(.removeFavoritePrimeTapped)),
                .offlineCounterView(.primeModal(.removeFavoritePrimeTapped)):
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
        case .counterView(.primeModal(.saveFavoritePrimeTapped)),
                .offlineCounterView(.primeModal(.saveFavoritePrimeTapped)):
            state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
        case let .favoritesPrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                state.activityFeed.append(
                    .init(timestamp: Date(), type: .removedFavoritePrime(state.favoritesPrimes[index]))
                )
            }
        }
        return reducer(&state, action, environment)
    }
}

//struct AppEnvironment {
//    var counter: CounterEnvironment
//    var favoritePrimes: FavoritePrimeEnvironment
//}

typealias AppEnvironment = (fileClient: FileClient, nthPrime: (Int) -> Effect<Int?>, offlineNthPrime: (Int) -> Effect<Int?>)

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = combine(
    pullback(counterViewReducer, value: \AppState.counterView, action: \AppAction.counterView, environment: { $0.nthPrime }),
    pullback(counterViewReducer, value: \AppState.counterView, action: \AppAction.offlineCounterView, environment: { $0.offlineNthPrime }),
    pullback(favoritePrimesReducer, value: \.favoritePrimesState, action: \.favoritesPrimes, environment: { ($0.fileClient, $0.nthPrime) })
)
