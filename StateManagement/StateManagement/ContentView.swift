//
//  ContentView.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI

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

enum CounterAction {
    case decrementTap
    case incrementTap
}

enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}

enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
}

enum AppAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    case favoritesPrimes(FavoritePrimesAction)
}

func appReducer(state: inout AppState, action: AppAction) {
    switch action {
    case .counter(.decrementTap):
        state.count -= 1
    case .counter(.incrementTap):
        state.count += 1
    case .primeModal(.removeFavoritePrimeTapped):
        state.favoritesPrimes.removeAll(where: { $0 == state.count })
        state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))
    case .primeModal(.saveFavoritePrimeTapped):
        state.favoritesPrimes.append(state.count)
        state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
    case let .favoritesPrimes(.deleteFavoritePrimes(indexSet)):
        for index in indexSet {
            let prime = state.favoritesPrimes[index]
            state.favoritesPrimes.remove(at: index)
            state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
        }
    }
}


final class Store<Value, Action>: ObservableObject {
    let reducer: (inout Value, Action) -> Void
    @Published var value: Value
    
    init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
        self.value = initialValue
        self.reducer = reducer
    }
    
    func send(_ action: Action) {
        self.reducer(&self.value, action)
    }
}

struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(store: self.store)) {
                    Text("Counter demo")
                }
                NavigationLink(destination: FavoritesPrimesView(store: self.store)) {
                    Text("Favorite primes")
                }
            }
            .navigationBarTitle("State Management")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: .init(initialValue: .init(), reducer: appReducer))
    }
}
