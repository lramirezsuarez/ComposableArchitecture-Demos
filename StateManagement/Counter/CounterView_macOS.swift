//
//  CounterView_macOS.swift
//  Counter
//
//  Created by Luis Alejandro Ramirez Suarez on 12/10/22.
//

#if os(macOS)
import SwiftUI
import ComposableArchitecture
import PrimeModal

public struct CounterView: View {
    struct State: Equatable {
        let alertNthPrime: PrimeAlert?
        let count: Int
        let isNthPrimeButtonDisabled: Bool
        let isPrimePopoverShown: Bool
    }
    enum Action {
        case decrementTap
        case incrementTap
        case nthPrimeButtonTapped
        case alertDismissButtonTapped
        case isPrimeButtonTapped
        case primePopoverDismissed
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
                Button("-") { self.viewStore.send(.decrementTap) }
                Text("\(self.viewStore.value.count)")
                Button("+") { self.viewStore.send(.incrementTap) }
            }
            HStack {
                Button("Is this prime?") { self.viewStore.send(.isPrimeButtonTapped) }
            }
            HStack {
                Button("What is the \(PrimeAlert.ordinal(self.viewStore.value.count)) prime?") { nthPrimeButtonAction() }
                .disabled(self.viewStore.value.isNthPrimeButtonDisabled)
            }
        }
        .popover(
            isPresented: Binding(
                get: { self.viewStore.value.isPrimePopoverShown },
                set: { _ in self.viewStore.send(.primePopoverDismissed) }
            )
        ) {
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
                        self.viewStore.send(.alertDismissButtonTapped)
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
        self.viewStore.send(.nthPrimeButtonTapped)
    }
}

extension CounterView.State {
    init(counterFeatureState: CounterFeatureState) {
        self.alertNthPrime = counterFeatureState.alertNthPrime
        self.count = counterFeatureState.count
        self.isNthPrimeButtonDisabled = counterFeatureState.isNthPrimeRequestInFlight
        self.isPrimePopoverShown = counterFeatureState.isPrimeDetailShown
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
        case .primePopoverDismissed:
            self = .counter(.primeDetailDismissed)
        }
    }
}
#endif
