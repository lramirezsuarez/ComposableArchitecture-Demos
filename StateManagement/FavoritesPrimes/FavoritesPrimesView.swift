//
//  FavoritesPrimesView.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI
import ComposableArchitecture

public struct FavoritesPrimesView: View {
    @ObservedObject var store: Store<[Int], FavoritePrimesAction>
    
    public init(store: Store<[Int], FavoritePrimesAction>) {
        self.store = store
    }
    
    public var body: some View {
        List {
            ForEach(store.value, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                self.store.send(.deleteFavoritePrimes(indexSet))
            }
        }
        .navigationTitle("Favorite Primes")
        .toolbar {
            HStack {
                Button("Save") {
                    self.store.send(.saveButtonTapped)
//                    let data = try! JSONEncoder().encode(self.store.value)
//                    let documentsPath = NSSearchPathForDirectoriesInDomains(
//                        .documentDirectory, .userDomainMask, true
//                    )[0]
//                    let documentsUrl = URL(fileURLWithPath: documentsPath)
//                    let favoritePrimesUrl = documentsUrl
//                        .appendingPathComponent("favorite-primes.json")
//                    try! data.write(to: favoritePrimesUrl)
                }
                Button("Load") {
                    self.store.send(.loadButtonTapped)
//                    let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//                    let documentsUrl = URL(fileURLWithPath: documentPath)
//                    let favoritesPrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
//                    guard let data = try? Data(contentsOf: favoritesPrimesUrl),
//                          let favoritesPrimes = try? JSONDecoder().decode([Int].self, from: data) else {
//                        return
//                    }
//                    self.store.send(.loadedFavoritePrimes(favoritesPrimes))
                }
            }
        }
    }
}

struct FavoritesPrimesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesPrimesView(
            store: Store<[Int], FavoritePrimesAction>(
                initialValue: [2,3,4,5,6],
                reducer: favoritePrimesReducer,
                environment: FavoritePrimeEnvironment.mock
            )
        )
    }
}
