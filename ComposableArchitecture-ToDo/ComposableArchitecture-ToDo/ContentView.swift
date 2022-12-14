//
//  ContentView.swift
//  ComposableArchitecture-ToDo
//
//  Created by Luis Alejandro Ramirez Suarez on 9/08/22.
//

import SwiftUI
import ComposableArchitecture

struct Todo: Equatable, Identifiable {
    var description = ""
    let id: UUID
    var isComplete = false
}

enum TodoAction: Equatable {
    case checkBoxTapped
    case textFieldChanged(String)
}

struct TodoEnvironment {
    
}

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, environment in
    switch action {
    case .checkBoxTapped:
        state.isComplete.toggle()
        return .none
    case .textFieldChanged(let text):
        state.description = text
        return .none
    }
}

struct AppState: Equatable {
    var todos: [Todo] = []
}

enum AppAction: Equatable {
    case addButtonTapped
    case todo(index: Int, action: TodoAction)
    case todoDelayedCompleted
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    todoReducer.forEach(
        state: \.todos,
    action: /AppAction.todo(index:action:),
    environment: { _ in TodoEnvironment() }),
    Reducer { state, action, environment in
        switch action {
        case .addButtonTapped:
            state.todos.insert(Todo(id: environment.uuid()), at: 0)
            return .none
        case .todo(index: _, action: .checkBoxTapped):
            struct CancelDelayId: Hashable {}
            
            return Effect(value: AppAction.todoDelayedCompleted)
                .debounce(id: CancelDelayId(), for: 1, scheduler: environment.mainQueue)
//                    .delay(for: 1, scheduler: DispatchQueue.main)
//                    .eraseToEffect()
//                    .cancellable(id: CancelDelayId(), cancelInFlight: true)
        case .todo(index: let index, action: let action):
            return .none
        case .todoDelayedCompleted:
            state.todos = state.todos.enumerated().sorted { lhs, rhs in
                !lhs.element.isComplete && rhs.element.isComplete || lhs.offset < rhs.offset
            }
            .map(\.element)
            
            return .none
        }
    }
).debug()

struct ContentView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                List {
                    ForEachStore(
                        self.store.scope(state: \.todos ,
                                         action: AppAction.todo(index:action:)),
                        content: TodoView.init(store:))
                }
                .navigationTitle("Todos")
                .toolbar {
                    ToolbarItem(content: {
                        Button("Add") {
                            viewStore.send(.addButtonTapped)
                        }
                    })
                }
            }
            
        }
    }
}

struct TodoView: View {
    let store: Store<Todo, TodoAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Button(action: { viewStore.send(.checkBoxTapped) }) {
                    Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(PlainButtonStyle())
                TextField("Untitle todo", text: viewStore.binding(
                    get: \.description,
                    send: TodoAction.textFieldChanged))
            }
            .foregroundColor(viewStore.isComplete ? .gray : nil)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(
            initialState: AppState(todos: [
                Todo(description: "Milk", id: UUID(), isComplete: false),
                Todo(description: "Eggs", id: UUID(), isComplete: false),
                Todo(description: "Hand Soap", id: UUID(), isComplete: true)
            ]),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                uuid: UUID.init)))
    }
}
