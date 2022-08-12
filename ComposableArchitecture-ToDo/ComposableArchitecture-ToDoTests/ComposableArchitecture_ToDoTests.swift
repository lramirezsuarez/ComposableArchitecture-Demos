//
//  ComposableArchitecture_ToDoTests.swift
//  ComposableArchitecture-ToDoTests
//
//  Created by Luis Alejandro Ramirez Suarez on 10/08/22.
//

import XCTest
import ComposableArchitecture
@testable import ComposableArchitecture_ToDo

class ComposableArchitecture_ToDoTests: XCTestCase {
    let scheduler = DispatchQueue.test

    func testCompletingTodo() {
        let uuid = UUID()
        let store = TestStore(
            initialState: AppState(todos: [
                Todo(description: "Milk", id: uuid, isComplete: false)
            ]),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { fatalError()}))
        
        store.assert(
            .send(.todo(index: 0, action: .checkBoxTapped)) {
                $0.todos[0].isComplete = true
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.todoDelayedCompleted)
        )
    }
    
    func testAddTodo() {
        let store = TestStore(
            initialState: AppState(),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")! })
        )
        
        store.assert(.send(.addButtonTapped) {
            $0.todos = [
                Todo(description: "",
                     id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!,
                     isComplete: false)
            ]
        })
    }
    
    func testTodoSorting() {
        let uuid = UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEDA")!
        let uuid1 = UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!
        
        let store = TestStore(
            initialState: AppState(todos: [
                Todo(description: "Milk", id: uuid, isComplete: false),
                Todo(description: "Eggs", id: uuid1, isComplete: false)
            ]),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { fatalError() }))
        
        store.assert(
            .send(.todo(index: 0, action: .checkBoxTapped)) {
                $0.todos[0].isComplete = true
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.todoDelayedCompleted) {
                $0.todos.swapAt(0, 1)
            }
        )
    }
    
    func testTodoSortingCancelation() {
        let uuid = UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEDA")!
        let uuid1 = UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!
        
        let store = TestStore(
            initialState: AppState(todos: [
                Todo(description: "Milk", id: uuid, isComplete: false),
                Todo(description: "Eggs", id: uuid1, isComplete: false)
            ]),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                uuid: { fatalError() }))
        
        store.assert(
            .send(.todo(index: 0, action: .checkBoxTapped)) {
                $0.todos[0].isComplete = true
            },
            .do {
                self.scheduler.advance(by: 0.5)
            },
            .send(.todo(index: 0, action: .checkBoxTapped)) {
                $0.todos[0].isComplete = false
            },
            .do {
                self.scheduler.advance(by: 1)
            },
            .receive(.todoDelayedCompleted)
        )
    }

}
