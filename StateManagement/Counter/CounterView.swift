//
//  CounterView.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI
import ComposableArchitecture
import PrimeModal

public struct PrimeAlert: Identifiable {
    let prime: Int
    public var id: Int { self.prime }
}

public struct CounterView: View {
    @ObservedObject var store: Store<CounterViewState, CounterViewAction>
    
    @State var isPrimeModalShown: Bool = false
    
    public init(store: Store<CounterViewState, CounterViewAction>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            HStack {
                Button(action: { self.store.send(.counter(.decrementTap)) }) {
                    Image(systemName: "minus")
                }
                Text("\(self.store.value.count)")
                Button(action: { self.store.send(.counter(.incrementTap)) }) {
                    Image(systemName: "plus")
                }
            }.padding()
            HStack {
                Button(action: { self.isPrimeModalShown.toggle() }) {
                    Text("Is this prime?")
                }
            }.padding()
            HStack {
                Button(action: { nthPrimeButtonAction() }) {
                    Text("What is the \(ordinal(self.store.value.count)) prime?")
                }
                .disabled(self.store.value.isNthPrimeButtonDisabled)
            }.padding()
        }
        .font(.title)
        .navigationBarTitle("Counter Demo")
        .sheet(isPresented: self.$isPrimeModalShown, onDismiss: { self.isPrimeModalShown = false }) {
            IsPrimeModalShown(store: self.store.view(
                value: { PrimeModalState(count: $0.count, favoritesPrimes: $0.favoritePrimes) },
                action: { .primeModal($0) })
            )
        }
        .alert(
            item: .constant(self.store.value.alertNthPrime)
        ) { alert in
            Alert(
                title: Text("The \(ordinal(self.store.value.count)) prime is \(alert.prime)"),
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
