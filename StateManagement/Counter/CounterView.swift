//
//  CounterView.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI
import ComposableArchitecture
import PrimeModal

public typealias CounterViewState = (count: Int, favoritesPrimes: [Int])

public enum CounterViewAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
}

public struct CounterView: View {
    @ObservedObject var store: Store<CounterViewState, CounterViewAction>
    
    @State var isPrimeModalShown: Bool = false
    @State var alertNthPrime: Bool = false
    @State var nthPrimeReceived: Int?
    @State var isNthPrimeButtonDisabled = false
    
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
                .disabled(self.isNthPrimeButtonDisabled)
            }.padding()
        }
        .font(.title)
        .navigationBarTitle("Counter Demo")
        .sheet(isPresented: self.$isPrimeModalShown, onDismiss: { self.isPrimeModalShown = false }) {
            IsPrimeModalShown(store: self.store.view(
                value: { PrimeModalState(count: $0.count, favoritesPrimes: $0.favoritesPrimes) },
                action: { .primeModal($0) })
            )
        }
        .alert("\(self.store.value.count)nth Prime",
               isPresented: self.$alertNthPrime,
               presenting: self.nthPrimeReceived) { _ in } message: { primeReceived in
            Text("The \(self.store.value.count)nth Prime received is \(primeReceived)")
        }

    }
    
    func nthPrimeButtonAction() {
        self.isNthPrimeButtonDisabled = true
        nthPrime(self.store.value.count) { nthPrime in
            self.isNthPrimeButtonDisabled = false
            guard let nthPrime = nthPrime else {
                return
            }
            
            self.alertNthPrime = true
            self.nthPrimeReceived = nthPrime
        }
    }
}

//struct CounterView_Previews: PreviewProvider {
//    static var previews: some View {
//        CounterView(store: .init(initialValue: .init(), reducer: appReducer))
//    }
//}
