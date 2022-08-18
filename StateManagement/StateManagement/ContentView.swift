//
//  ContentView.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(state: self.state)) {
                    Text("Counter demo")
                }
                NavigationLink(destination: EmptyView()) {
                    Text("Favorite primes")
                }
            }
            .navigationBarTitle("State Management")
        }
    }
}

class AppState: ObservableObject {
    @Published var count: Int = 0
}

struct CounterView: View {
    @ObservedObject var state: AppState
    
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
                Button(action: { }) {
                    Text("Is this prime?")
                }
            }.padding()
            HStack {
                Button(action: { }) {
                    Text("What is the \(ordinal(self.state.count)) prime?")
                }
            }.padding()
        }
        .font(.title)
        .navigationBarTitle("Counter Demo")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(state: .init())
    }
}

private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}
