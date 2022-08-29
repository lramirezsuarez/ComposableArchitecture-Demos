//
//  FavoritesPrimesView.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI
import ComposableArchitecture

struct FavoritesPrimesView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        List {
            ForEach(store.value.favoritesPrimes, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                self.store.send(.favoritesPrimes(.deleteFavoritePrimes(indexSet)))
            }
        }
        .navigationTitle("Favorite Primes")
    }
}

struct FavoritesPrimesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesPrimesView(store: .init(initialValue: .init(), reducer: appReducer))
    }
}
