//
//  FavoritesPrimes.swift
//  FavoritesPrimes
//
//  Created by Luis Alejandro Ramirez Suarez on 29/08/22.
//

import ComposableArchitecture
import Combine
import PrimeAlert

public enum FavoritePrimesAction: Equatable {
    case deleteFavoritePrimes(IndexSet)
    case loadedFavoritePrimes([Int])
    case loadButtonTapped
    case saveButtonTapped
    case primeButtonTapped(Int)
    case nthPrimeResponse(n: Int, prime: Int?)
    case alertDimissButtonTapped
}

public typealias FavoritePrimeState = (alertNthPrime: PrimeAlert?,
                                       favoritePrimes: [Int])

public let favoritePrimesReducer = Reducer<FavoritePrimeState, FavoritePrimesAction, FavoritePrimeEnvironment> { state, action, environment in
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        for index in indexSet {
            state.favoritePrimes.remove(at: index)
        }
        return []
        
    case let .loadedFavoritePrimes(favoritesPrimes):
        state.favoritePrimes = favoritesPrimes
        return []
        
    case .loadButtonTapped:
        return [
            environment.fileClient.load("favorite-primes.json")
                .compactMap { $0 }
                .decode(type: [Int].self, decoder: JSONDecoder())
                .catch { error in Empty(completeImmediately: true) }
                .map(FavoritePrimesAction.loadedFavoritePrimes)
                .eraseToEffect()
        ]
        
    case .saveButtonTapped:
        return [environment.fileClient.save("favorite-primes.json", try! JSONEncoder().encode(state.favoritePrimes))
            .fireAndForget()]
        
    case let .primeButtonTapped(n):
        return [
            environment.nthPrime(n)
                .map { FavoritePrimesAction.nthPrimeResponse(n: n, prime: $0) }
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
        ]
        
    case .nthPrimeResponse(let n, let prime):
        state.alertNthPrime = prime.map { PrimeAlert(n: n, prime: $0)}
        return []
        
    case .alertDimissButtonTapped:
        state.alertNthPrime = nil
        return []
    }
}

extension Publisher where Output == Never, Failure == Never {
    func fireAndForget<A>() -> Effect<A> {
        return self.map(absurd).eraseToEffect()
    }
}

func absurd<A>(_ never: Never) -> A { }

public struct FileClient {
    var load: (String) -> Effect<Data?>
    var save: (String, Data) -> Effect<Never>
}

extension FileClient {
    public static let live = Self(
        load: { fileName in
                .sync {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let documentsUrl = URL(fileURLWithPath: documentsPath)
                    let favoritePrimesUrl = documentsUrl.appendingPathComponent(fileName)
                    return try? Data(contentsOf: favoritePrimesUrl)
                }
        },
        save: { fileName, data in
                .fireAndForget {
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let documentsUrl = URL(fileURLWithPath: documentsPath)
                    let favoritePrimesUrl = documentsUrl.appendingPathComponent(fileName)
                    try! data.write(to: favoritePrimesUrl)
                }
        })
}

public typealias FavoritePrimeEnvironment = (fileClient: FileClient, nthPrime: (Int) -> Effect<Int?>)

#if DEBUG
extension FileClient {
    static let mock = FavoritePrimeEnvironment(fileClient: FileClient(
        load: { _ in Effect<Data?>.sync {
            try! JSONEncoder().encode([2, 31])
        }
        },
        save: { _, _ in .fireAndForget { } }
    ),
                                               nthPrime: { _ in .sync { 17 } })
}
#endif
