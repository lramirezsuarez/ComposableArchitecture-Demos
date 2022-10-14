//
//  CounterView_iOS.swift
//  Counter
//
//  Created by Luis Alejandro Ramirez Suarez on 12/10/22.
//

#if os(iOS)
import SwiftUI
import ComposableArchitecture
import PrimeModal
import PrimeAlert

public struct CounterView: View {
    struct State: Equatable {
        let alertNthPrime: PrimeAlert?
        let count: Int
        let isNthPrimeButtonDisabled: Bool
        let isPrimeModalShown: Bool
    }
    enum Action {
        case decrementTap
        case incrementTap
        case nthPrimeButtonTapped
        case alertDismissButtonTapped
        case isPrimeButtonTapped
        case primeModalDismissed
    }
    
    let store: Store<CounterFeatureState, CounterFeatureAction>
    @ObservedObject var viewStore: ViewStore<State, Action>
    
    public init(store: Store<CounterFeatureState, CounterFeatureAction>) {
        self.store = store
        self.viewStore = self.store
            .scope(value: State.init,
                   action: CounterFeatureAction.init)
            .view
    }
    
    public var body: some View {
        VStack {
            HStack {
                Button(action: { self.viewStore.send(.decrementTap) }) {
                    Image(systemName: "minus")
                }
                Text("\(self.viewStore.count)")
                Button(action: { self.viewStore.send(.incrementTap) }) {
                    Image(systemName: "plus")
                }
            }.padding()
            HStack {
                Button(action: { self.viewStore.send(.isPrimeButtonTapped) }) {
                    Text("Is this prime?")
                }
            }.padding()
            HStack {
                Button(action: { nthPrimeButtonAction() }) {
                    Text("What is the \(PrimeAlert.ordinal(self.viewStore.count)) prime?")
                }
                .disabled(self.viewStore.isNthPrimeButtonDisabled)
            }.padding()
        }
        .font(.title)
        .navigationBarTitle("Counter Demo")
        .sheet(
            isPresented: self.viewStore.binding(
                get: \.isPrimeModalShown,
                send: Action.primeModalDismissed
            )
        ) {
            IsPrimeModalShown(store: self.store.scope(
                value: { PrimeModalState(count: $0.count, favoritesPrimes: $0.favoritePrimes) },
                action: { .primeModal($0) })
            )
        }
               .alert(
                item: self.viewStore.binding(
                    get: \.alertNthPrime,
                    send: .alertDismissButtonTapped
                )
               ) { alert in
                   Alert(title: Text(alert.title))
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
        self.viewStore.send(.nthPrimeButtonTapped)
    }
}

extension CounterView.State {
    init(counterFeatureState: CounterFeatureState) {
        self.alertNthPrime = counterFeatureState.alertNthPrime
        self.count = counterFeatureState.count
        self.isNthPrimeButtonDisabled = counterFeatureState.isNthPrimeRequestInFlight
        self.isPrimeModalShown = counterFeatureState.isPrimeDetailShown
    }
}

extension CounterFeatureAction {
    init(counterViewAction action: CounterView.Action) {
        switch action {
        case .decrementTap:
            self = .counter(.decrementTap)
        case .incrementTap:
            self = .counter(.incrementTap)
        case .nthPrimeButtonTapped:
            self = .counter(.requestNthPrime)
        case .alertDismissButtonTapped:
            self = .counter(.alertDismissButtonTapped)
        case .isPrimeButtonTapped:
            self = .counter(.isPrimeButtonTapped)
        case .primeModalDismissed:
            self = .counter(.primeDetailDismissed)
        }
    }
}
#endif
