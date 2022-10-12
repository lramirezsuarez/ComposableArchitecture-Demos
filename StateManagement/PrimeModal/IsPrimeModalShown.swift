//
//  IsPrimeModalShown.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI
import ComposableArchitecture

public struct IsPrimeModalShown: View {
    struct State: Equatable {
        let count: Int
        let isFavorite: Bool
    }
    
    let store: Store<PrimeModalState, PrimeModalAction>
    @ObservedObject var viewStore: ViewStore<State, PrimeModalAction>
    
    public init(store: Store<PrimeModalState, PrimeModalAction>) {
        self.store = store
        self.viewStore = self.store
            .scope(value: State.init(primeModalState:),
                   action: { $0 })
            .view
    }
    
    public var body: some View {
        VStack {
            Text("The number \(self.viewStore.value.count) \(isPrime() ? "Is Prime" : "Is Not Prime")")
            if isPrime() {
                Button(action: { self.addRemoveFavoritePrime() }) {
                    Text("\(primeInFavorites() ? "Remove from" : "Save to") favorites primes")
                }
            }
        }
    }
    
    func isPrime() -> Bool {
        let isPrime = self.viewStore.value.count > 1 && !(2..<self.viewStore.value.count).contains { self.viewStore.value.count % $0 == 0 }
        return isPrime
    }
    
    func primeInFavorites() -> Bool {
        return self.viewStore.value.isFavorite
    }
    
    func addRemoveFavoritePrime() {
        if primeInFavorites() {
            self.viewStore.send(.removeFavoritePrimeTapped)
        } else {
            self.viewStore.send(.saveFavoritePrimeTapped)
        }
    }
}

struct IsPrimeModalShown_Previews: PreviewProvider {
    static var previews: some View {
        IsPrimeModalShown(
            store: Store<PrimeModalState, PrimeModalAction>(
                initialValue: PrimeModalState(count: 2, favoritesPrimes: [2,3,4,5,6]),
                reducer: primeModalReducer, environment: ()
            )
        )
    }
}

extension IsPrimeModalShown.State {
    init(primeModalState state: PrimeModalState) {
        self.count = state.count
        self.isFavorite = state.favoritesPrimes.contains(state.count)
    }
}
