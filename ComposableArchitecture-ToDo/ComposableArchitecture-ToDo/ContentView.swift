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

enum TodoAction {
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
    var todos: IdentifiedArrayOf<Todo>
}

enum AppAction {
    case addButtonTapped
    case todo(id: Todo.ID, action: TodoAction)
}

struct AppEnvironment {
    
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    todoReducer.forEach(
        state: \.todos,
    action: /AppAction.todo(id:action:),
    environment: { _ in TodoEnvironment() }),
    Reducer { state, action, environment in
        switch action {
        case .addButtonTapped:
            state.todos.insert(Todo(id: UUID()), at: 0)
            return .none
        case .todo(id: let id, action: let action):
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
                                         action: AppAction.todo(id:action:)),
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
            environment: AppEnvironment()))
    }
}
