//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Luis Alejandro Ramirez Suarez on 29/08/22.
//

public typealias PrimeModalState = (count: Int, favoritesPrimes: [Int])

public enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}

public func primeModalReducer(state: inout PrimeModalState, action: PrimeModalAction) {
    switch action {
    case .removeFavoritePrimeTapped:
        state.favoritesPrimes.removeAll(where: { $0 == state.count })
    case .saveFavoritePrimeTapped:
        state.favoritesPrimes.append(state.count)
    }
}
