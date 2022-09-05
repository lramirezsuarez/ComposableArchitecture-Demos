//
//  FavoritesPrimes.swift
//  FavoritesPrimes
//
//  Created by Luis Alejandro Ramirez Suarez on 29/08/22.
//

import ComposableArchitecture

public enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
    case loadedFavoritePrimes([Int])
    case saveButtonTapped
}

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) -> Effect {
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
        return {}
        
    case let .loadedFavoritePrimes(favoritesPrimes):
        state = favoritesPrimes
        return {}
        
    case .saveButtonTapped:
        let state = state
        return {
            let data = try! JSONEncoder().encode(state)
            let documentsPath = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            )[0]
            let documentsUrl = URL(fileURLWithPath: documentsPath)
            let favoritePrimesUrl = documentsUrl
                .appendingPathComponent("favorite-primes.json")
            try! data.write(to: favoritePrimesUrl)
        }
    }
}
