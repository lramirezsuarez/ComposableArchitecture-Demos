//
//  CounterView.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI

struct CounterView: View {
    @ObservedObject var state: AppState
    @State var isPrimeModalShown: Bool = false
    @State var alertNthPrime: Bool = false
    @State var nthPrimeReceived: Int?
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { self.state.count -= 1 }) {
                    Image(systemName: "minus")
                }
                Text("\(self.state.count)")
                Button(action: { self.state.count += 1 }) {
                    Image(systemName: "plus")
                }
            }.padding()
            HStack {
                Button(action: { self.isPrimeModalShown.toggle() }) {
                    Text("Is this prime?")
                }
            }.padding()
            HStack {
                Button(action: { nthPrime(self.state.count) { nthPrime in
                    guard let nthPrime = nthPrime else {
                        return
                    }
                    
                    self.alertNthPrime = true
                    self.nthPrimeReceived = nthPrime
                }}) {
                    Text("What is the \(ordinal(self.state.count)) prime?")
                }
            }.padding()
        }
        .font(.title)
        .navigationBarTitle("Counter Demo")
        .sheet(isPresented: self.$isPrimeModalShown, onDismiss: { self.isPrimeModalShown = false }) {
            IsPrimeModalShown(state: self.state)
        }
        .alert("\(self.state.count)nth Prime",
               isPresented: self.$alertNthPrime,
               presenting: nthPrimeReceived) { _ in } message: { primeReceived in
            Text("The \(self.state.count)nth Prime received is \(primeReceived)")
        }

    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(state: .init())
    }
}
