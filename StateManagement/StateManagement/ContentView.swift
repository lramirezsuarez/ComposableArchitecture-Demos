//
//  ContentView.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import Counter
import SwiftUI
import Overture
import ComposableArchitecture
import FavoritesPrimes

struct ContentView: View {
    let store: Store<AppState, AppAction>
//    @ObservedObject var viewStore: ViewStore<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Counter demo", destination:  CounterView(store: self.store.scope(
                    value: { $0.counterView },
                    action: { .counterView($0) })))
                NavigationLink("Offline Counter demo", destination:  CounterView(store: self.store.scope(
                    value: { $0.counterView },
                    action: { .offlineCounterView($0) })))
                NavigationLink("Favorite primes", destination: FavoritesPrimesView(store: self.store.scope(
                    value:  { FavoritePrimeState(alertNthPrime: nil, favoritePrimes: $0.favoritesPrimes) },
                    action: { .favoritesPrimes($0) })))
            }
            .navigationBarTitle("State Management")
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(store: .init(initialValue: .init(), reducer: logging(activityFeed(appReducer))))
//    }
//}
