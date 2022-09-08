//
//  State.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 24/08/22.
//

import Counter

struct AppState {
    var count: Int = 0
    var favoritesPrimes: [Int] = []
    var loggedInUser: User?
    var activityFeed: [Activity] = []
    var alertNthPrime: PrimeAlert? = nil
    var isNthPrimeButtonDisabled: Bool = false
    
    struct Activity {
        let timestamp: Date
        let type: ActivityType
        
        enum ActivityType {
            case addedFavoritePrime(Int)
            case removedFavoritePrime(Int)
        }
    }
    
    struct User {
        let id: Int
        let name: String
        let bio: String
    }
}

extension AppState {
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
