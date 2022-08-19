//
//  FavoritesPrimesView.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI

struct FavoritesPrimesView: View {
    @Binding var favoritePrimes: [Int]
    @Binding var activityFeed: [AppState.Activity]
    
    var body: some View {
        List {
            ForEach(favoritePrimes, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let prime = favoritePrimes[index]
                    favoritePrimes.remove(at: index)
                    activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
                }
            }
        }
        .navigationTitle("Favorite Primes")
    }
}

struct FavoritesPrimesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesPrimesView(favoritePrimes: .constant([0]), activityFeed: .constant([.init(timestamp: Date(), type: .addedFavoritePrime(0))]))
    }
}
