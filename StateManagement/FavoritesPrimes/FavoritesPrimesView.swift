//
//  FavoritesPrimesView.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI
import ComposableArchitecture

public struct FavoritesPrimesView: View {
    let store: Store<FavoritePrimeState, FavoritePrimesAction>
    @ObservedObject var viewStore: ViewStore<FavoritePrimeState, FavoritePrimesAction>
    
    public init(store: Store<FavoritePrimeState, FavoritePrimesAction>) {
        self.store = store
        self.viewStore = self.store.view(removeDuplicated: ==)
    }
    
    public var body: some View {
        List {
            ForEach(self.viewStore.value.favoritePrimes, id: \.self) { prime in
                Button("\(prime)") {
                    self.viewStore.send(.primeButtonTapped(prime))
                }
            }
            .onDelete { indexSet in
                self.viewStore.send(.deleteFavoritePrimes(indexSet))
            }
        }
        .navigationTitle("Favorite Primes")
        .toolbar {
            HStack {
                Button("Save") {
                    self.viewStore.send(.saveButtonTapped)
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
                    self.viewStore.send(.loadButtonTapped)
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
        .alert(item: .constant(self.viewStore.value.alertNthPrime)) { alert in
            Alert(title: Text(alert.title),
                  dismissButton: .default(Text("Ok"))  {
                self.viewStore.send(.alertDimissButtonTapped)
            }
            )
            
        }
    }
}

struct FavoritesPrimesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesPrimesView(
            store: Store<FavoritePrimeState, FavoritePrimesAction>(
                initialValue: FavoritePrimeState(alertNthPrime: nil, favoritePrimes: [2,3,4,5,6]),
                reducer: favoritePrimesReducer,
                environment: FileClient.mock
            )
        )
    }
}
