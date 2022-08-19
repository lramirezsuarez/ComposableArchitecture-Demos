//
//  ContentView.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var count: Int = 0
    @Published var favoritesPrimes: [Int] = []
    @Published var loggedInUser: User?
    @Published var activityFeed: [Activity] = []
    
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
    func addFavoritePrime() {
        self.favoritesPrimes.append(self.count)
        self.activityFeed.append(Activity(timestamp: Date(), type: .addedFavoritePrime(self.count)))
    }
    
    func removeFavoritePrime(_ prime: Int) {
        self.favoritesPrimes.removeAll(where: { $0 == prime })
        self.activityFeed.append(Activity(timestamp: Date(), type: .removedFavoritePrime(prime)))
    }
    
    func removeFavoritePrime() {
        self.removeFavoritePrime(self.count)
    }
    
    func removeFavoritePrimes(at indexSet: IndexSet) {
        for index in indexSet {
            self.removeFavoritePrime(self.favoritesPrimes[index])
        }
    }
}

struct ContentView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(state: self.state)) {
                    Text("Counter demo")
                }
                NavigationLink(destination: FavoritesPrimesView(
                    favoritePrimes: self.$state.favoritesPrimes,
                    activityFeed: self.$state.activityFeed)) {
                    Text("Favorite primes")
                }
            }
            .navigationBarTitle("State Management")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(state: .init())
    }
}
