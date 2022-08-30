//
//  ContentView.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI
import Overture
import ComposableArchitecture

struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(store: self.store.view { ($0.count, $0.favoritesPrimes) })) {
                    Text("Counter demo")
                }
                NavigationLink(destination: FavoritesPrimesView(store: self.store.view { $0.favoritesPrimes })) {
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
