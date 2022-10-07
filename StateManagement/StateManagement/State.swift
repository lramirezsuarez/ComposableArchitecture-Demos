//
//  State.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 24/08/22.
//

import Counter
import FavoritesPrimes

struct AppState: Equatable {
    var count: Int = 0
    var favoritesPrimes: [Int] = []
    var loggedInUser: User?
    var activityFeed: [Activity] = []
    var alertNthPrime: PrimeAlert? = nil
    var isNthPrimeButtonDisabled: Bool = false
    
    struct Activity: Equatable {
        let timestamp: Date
        let type: ActivityType
        
        enum ActivityType: Equatable {
            case addedFavoritePrime(Int)
            case removedFavoritePrime(Int)
        }
    }
    
    struct User: Equatable {
        let id: Int
        let name: String
        let bio: String
    }
}

extension AppState {
    var favoritePrimesState: FavoritePrimeState {
        get {
            (self.alertNthPrime, self.favoritesPrimes)
        }
        set {
            (self.alertNthPrime, self.favoritesPrimes)
        }
    }
    
    var counterView: CounterViewState {
        get {
            CounterViewState(
                alertNthPrime: self.alertNthPrime,
                count: self.count,
                favoritePrimes: self.favoritesPrimes,
                isNthPrimeButtonDisabled: self.isNthPrimeButtonDisabled)
        }
        set {
            self.alertNthPrime = newValue.alertNthPrime
            self.isNthPrimeButtonDisabled = newValue.isNthPrimeButtonDisabled
            self.count = newValue.count
            self.favoritesPrimes = newValue.favoritePrimes
        }
    }
}
