//
//  CounterView.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI
import ComposableArchitecture
import PrimeModal

public struct PrimeAlert: Identifiable, Equatable {
    public let n: Int
    public let prime: Int
    public var id: Int { self.prime }
    
    public init(n: Int, prime: Int) {
        self.n = n
        self.prime = prime
    }
    
    public var title: String {
        return "The \(ordinal(self.n)) prime is \(self.prime)"
    }
}

public struct CounterView: View {
    struct State: Equatable {
        let alertNthPrime: PrimeAlert?
        let count: Int
        let isNthPrimeButtonDisabled: Bool
        let isPrimeModalShown: Bool
    }
    
    let store: Store<CounterFeatureState, CounterFeatureAction>
    @ObservedObject var viewStore: ViewStore<State>
    
    public init(store: Store<CounterFeatureState, CounterFeatureAction>) {
        self.store = store
        self.viewStore = self.store
            .scope(value: State.init(counterFeatureState:),
                   action: { $0 })
            .view
    }
    
    public var body: some View {
        VStack {
            HStack {
                Button(action: { self.store.send(.counter(.decrementTap)) }) {
                    Image(systemName: "minus")
                }
                Text("\(self.viewStore.value.count)")
                Button(action: { self.store.send(.counter(.incrementTap)) }) {
                    Image(systemName: "plus")
                }
            }.padding()
            HStack {
                Button(action: { self.store.send(.counter(.isPrimeButtonTapped)) }) {
                    Text("Is this prime?")
                }
            }.padding()
            HStack {
                Button(action: { nthPrimeButtonAction() }) {
                    Text("What is the \(ordinal(self.viewStore.value.count)) prime?")
                }
                .disabled(self.viewStore.value.isNthPrimeButtonDisabled)
            }.padding()
        }
        .font(.title)
        .navigationBarTitle("Counter Demo")
        .sheet(isPresented: .constant(self.viewStore.value.isPrimeModalShown),
               onDismiss: { self.store.send(.counter(.primeModalDismissed)) }) {
            IsPrimeModalShown(store: self.store.scope(
                value: { PrimeModalState(count: $0.count, favoritesPrimes: $0.favoritePrimes) },
                action: { .primeModal($0) })
            )
        }
        .alert(
            item: .constant(self.viewStore.value.alertNthPrime)
        ) { alert in
            Alert(
                title: Text(alert.title),
                dismissButton: .default(Text("Ok")) {
                    self.store.send(.counter(.alertDismissButtonTapped))
                }
            )
        }

    }
    
    func nthPrimeButtonAction() {
//        self.isNthPrimeButtonDisabled = true
//        nthPrime(self.store.value.count) { nthPrime in
//            self.isNthPrimeButtonDisabled = false
//            guard let nthPrime = nthPrime else {
//                return
//            }
//
//            self.alertNthPrime = true
//            self.nthPrimeReceived = nthPrime
//        }
        self.store.send(.counter(.nthPrimeButtonTapped))
    }
}

extension CounterView.State {
    init(counterFeatureState: CounterFeatureState) {
        self.alertNthPrime = counterFeatureState.alertNthPrime
        self.count = counterFeatureState.count
        self.isNthPrimeButtonDisabled = counterFeatureState.isNthPrimeRequestInFlight
        self.isPrimeModalShown = counterFeatureState.isPrimeModalShown
    }
}

//struct CounterView_Previews: PreviewProvider {
//    static var previews: some View {
//        CounterView(
//            store: Store<CounterViewState, CounterViewAction>(
//                initialValue: (1_000_000, []),
//                reducer: counterViewReducer
//            )
//        )
//    }
//}
