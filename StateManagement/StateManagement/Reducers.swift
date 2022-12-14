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

extension Reducer where Value == AppState, Action == AppAction, Environment == AppEnvironment {
    func activityFeed() -> Reducer<AppState, AppAction, AppEnvironment> {
        return .init { state, action, environment in
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
            return self(&state, action, environment)
        }
    }
}



//struct AppEnvironment {
//    var counter: CounterEnvironment
//    var favoritePrimes: FavoritePrimeEnvironment
//}

typealias AppEnvironment = (fileClient: FileClient, nthPrime: (Int) -> Effect<Int?>, offlineNthPrime: (Int) -> Effect<Int?>)

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer.combine(
    counterFeatureReducer.pullback(value: \AppState.counterView, action: \AppAction.counterView, environment: { $0.nthPrime }),
    counterFeatureReducer.pullback(value: \AppState.counterView, action: \AppAction.offlineCounterView, environment: { $0.offlineNthPrime }),
    favoritePrimesReducer.pullback(value: \.favoritePrimesState, action: \.favoritesPrimes, environment: { ($0.fileClient, $0.nthPrime) })
)
