//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Luis Alejandro Ramirez Suarez on 29/08/22.
//

import ComposableArchitecture

public typealias PrimeModalState = (count: Int, favoritesPrimes: [Int])

public enum PrimeModalAction: Equatable {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}

public let primeModalReducer = Reducer<PrimeModalState, PrimeModalAction, Void> { state, action, _ in
    switch action {
    case .removeFavoritePrimeTapped:
        state.favoritesPrimes.removeAll(where: { $0 == state.count })
        return []
    case .saveFavoritePrimeTapped:
        state.favoritesPrimes.append(state.count)
        return []
    }
}
