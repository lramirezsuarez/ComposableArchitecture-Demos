//
//  IsPrimeModalShown.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI

struct IsPrimeModalShown: View {
    @ObservedObject var state: AppState
    var body: some View {
        VStack {
            Text("The number \(self.state.count) \(isPrime())")
            Button(action: { self.addRemoveFavoritePrime() }) {
                Text("\(primeInFavorites() ? "Remove from" : "Save to") favorites primes")
            }
        }
    }
    
    func isPrime() -> String {
        let isPrime = self.state.count > 1 && !(2..<self.state.count).contains { self.state.count % $0 == 0 }
        return isPrime ? "Is Prime" : "Is Not Prime"
    }
    
    func primeInFavorites() -> Bool {
        return self.state.favoritesPrimes.contains(self.state.count)
    }
    
    func addRemoveFavoritePrime() {
        if primeInFavorites() {
            self.state.favoritesPrimes.removeAll(where: { $0 == self.state.count })
        } else {
            self.state.favoritesPrimes.append(self.state.count)
        }
    }
}

struct IsPrimeModalShown_Previews: PreviewProvider {
    static var previews: some View {
        IsPrimeModalShown(state: .init())
    }
}
