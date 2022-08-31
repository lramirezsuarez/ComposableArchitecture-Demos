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
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(store: self.store.view(
                    value: { ($0.count, $0.favoritesPrimes) },
                    action: {
                        switch $0 {
                        case let .counter(action):
                            return AppAction.counter(action)
                        case let .primeModal(action):
                            return AppAction.primeModal(action)
                        }
                    }) )) {
                    Text("Counter demo")
                }
                NavigationLink(destination: FavoritesPrimesView(store: self.store.view(
                    value:  { $0.favoritesPrimes },
                    action: { .favoritesPrimes($0) }))) {
                    Text("Favorite primes")
                }
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
