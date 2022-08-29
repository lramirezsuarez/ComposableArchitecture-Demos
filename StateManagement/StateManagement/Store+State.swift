//
//  Store+State.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 24/08/22.
//

import PrimeModal

struct AppState {
    var count: Int = 0
    var favoritesPrimes: [Int] = []
    var loggedInUser: User?
    var activityFeed: [Activity] = []
    
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
    var primeModal: PrimeModalState {
        get {
            PrimeModalState(count: self.count, favoritesPrimes: self.favoritesPrimes)
        }
        set {
            self.count = newValue.count
            self.favoritesPrimes = newValue.favoritesPrimes
        }
    }
}
