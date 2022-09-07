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
    case loadButtonTapped
    case saveButtonTapped
}

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) -> [Effect<FavoritePrimesAction>] {
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
        return []
        
    case let .loadedFavoritePrimes(favoritesPrimes):
        state = favoritesPrimes
        return []
        
    case .loadButtonTapped:
        return [loadEffect]
        
    case .saveButtonTapped:
        return [saveEffect(favoritePrimes: state)]
    }
}

private func saveEffect(favoritePrimes: [Int]) -> Effect<FavoritePrimesAction> {
    return { 
        let data = try! JSONEncoder().encode(favoritePrimes)
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        )[0]
        let documentsUrl = URL(fileURLWithPath: documentsPath)
        let favoritePrimesUrl = documentsUrl
            .appendingPathComponent("favorite-primes.json")
        try! data.write(to: favoritePrimesUrl)
        return nil
    }
}

private let loadEffect: Effect<FavoritePrimesAction> = { callback in
    let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let documentsUrl = URL(fileURLWithPath: documentPath)
    let favoritesPrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
    guard let data = try? Data(contentsOf: favoritesPrimesUrl),
          let favoritesPrimes = try? JSONDecoder().decode([Int].self, from: data) else {
        return nil
    }
    return .loadedFavoritePrimes(favoritesPrimes)
}
