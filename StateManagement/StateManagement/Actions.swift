//
//  Actions.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 24/08/22.
//

import Counter
import Foundation
import FavoritesPrimes
import PrimeModal

enum AppAction {
    case counterView(CounterViewAction)
    case favoritesPrimes(FavoritePrimesAction)
    
    var counterView: CounterViewAction? {
        get {
            guard case let .counterView(value) = self else { return nil }
            return value
        }
        set {
            guard case .counterView = self, let newValue = newValue else { return }
            self = .counterView(newValue)
        }
    }
    
    var favoritesPrimes: FavoritePrimesAction? {
        get {
            guard case let .favoritesPrimes(value) = self else { return nil }
            return value
        }
        set {
            guard case .favoritesPrimes = self, let newValue = newValue else { return }
            self = .favoritesPrimes(newValue)
        }
    }
}
