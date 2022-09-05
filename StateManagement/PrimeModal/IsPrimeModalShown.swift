//
//  IsPrimeModalShown.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI
import ComposableArchitecture

public struct IsPrimeModalShown: View {
    @ObservedObject var store: Store<PrimeModalState, PrimeModalAction>
    
    public init(store: Store<PrimeModalState, PrimeModalAction>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            Text("The number \(self.store.value.count) \(isPrime() ? "Is Prime" : "Is Not Prime")")
            if isPrime() {
                Button(action: { self.addRemoveFavoritePrime() }) {
                    Text("\(primeInFavorites() ? "Remove from" : "Save to") favorites primes")
                }
            }
        }
    }
    
    func isPrime() -> Bool {
        let isPrime = self.store.value.count > 1 && !(2..<self.store.value.count).contains { self.store.value.count % $0 == 0 }
        return isPrime
    }
    
    func primeInFavorites() -> Bool {
        return self.store.value.favoritesPrimes.contains(self.store.value.count)
    }
    
    func addRemoveFavoritePrime() {
        if primeInFavorites() {
            self.store.send(.removeFavoritePrimeTapped)
        } else {
            self.store.send(.saveFavoritePrimeTapped)
        }
    }
}

struct IsPrimeModalShown_Previews: PreviewProvider {
    static var previews: some View {
        IsPrimeModalShown(
            store: Store<PrimeModalState, PrimeModalAction>(
                initialValue: PrimeModalState(count: 2, favoritesPrimes: [2,3,4,5,6]),
                reducer: primeModalReducer
            )
        )
    }
}