//
//  ComposableArchitecture.swift
//  ComposableArchitecture
//
//  Created by Luis Alejandro Ramirez Suarez on 29/08/22.
//

import Combine
import SwiftUI

////public typealias Effect<Action> = (@escaping (Action) -> Void) -> Void
//public struct Effect<A> {
//    public let run: (@escaping (A) -> Void) -> Void
//
//    public init(run: @escaping (@escaping (A) -> Void) -> Void) {
//        self.run = run
//    }
//
//    public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
//        return Effect<B> { callback in self.run { a in callback(f(a)) }
//        }
//    }
//}

public struct Effect<Output>: Publisher {
    public typealias Failure = Never
    
    let publisher: AnyPublisher<Output, Failure>
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        self.publisher.receive(subscriber: subscriber)
    }
}

extension Publisher where Failure == Never {
    public func eraseToEffect() -> Effect<Output> {
        return Effect(publisher: self.eraseToAnyPublisher())
    }
}

//public typealias Reducer<Value, Action, Environment> = (inout Value, Action, Environment) -> [Effect<Action>]
public struct Reducer<Value, Action, Environment> {
    let reducer: (inout Value, Action, Environment) -> [Effect<Action>]
    
    public init(
        _ reducer: @escaping (inout Value, Action, Environment) -> [Effect<Action>]
    ) {
        self.reducer = reducer
    }
}

extension Reducer {
    public static func combine(
        _ reducers: Reducer...
    ) -> Reducer {
        return Reducer { value, action, environment in
            let effects = reducers.flatMap { $0(&value, action, environment) }
            return effects
        }
    }
    
    public func pullback<GlobalValue, GlobalAction, GlobalEnvironment>(
        value: WritableKeyPath<GlobalValue, Value>,
        action: WritableKeyPath<GlobalAction, Action?>,
        environment: @escaping (GlobalEnvironment) -> Environment
    ) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
        return .init{ globalValue, globalAction, globalEnvironment in
            guard let localAction = globalAction[keyPath: action] else { return [] }
            let localEffects = self(&globalValue[keyPath: value], localAction, environment(globalEnvironment))
            return localEffects.map { localEffect in
                localEffect.map { localAction -> GlobalAction in
                    var globalAction = globalAction
                    globalAction[keyPath: action] = localAction
                    return globalAction
                    
                }
                .eraseToEffect()
            }
        }
    }
    
    public func logging(
        printer: @escaping (Environment) -> (String) -> Void = { _ in { print($0) } }
    ) -> Reducer {
        return .init { value, action, environment in
            let effects = self(&value, action, environment)
            let newValue = value
            let print = printer(environment)
            return [.fireAndForget {
                print("Action: \(action)")
                print("Value:")
                var dumpedNewValue = ""
                dump(newValue, to: &dumpedNewValue)
                print(dumpedNewValue)
                print("---")
            }] + effects
        }
    }

}

@dynamicMemberLookup
public final class ViewStore<Value, Action>: ObservableObject {
    @Published public fileprivate(set) var value: Value
    fileprivate var cancellable: Cancellable?
    public let send: (Action) -> Void
    
    public subscript<LocalValue>(dynamicMember keyPath: KeyPath<Value, LocalValue>) -> LocalValue {
        self.value[keyPath: keyPath]
    }
    
    public init(initialValue value: Value, send: @escaping (Action) -> Void) {
        self.value = value
        self.send = send
    }
    
}

extension ViewStore {
    public func binding<LocalValue>(
        get: @escaping (Value) -> LocalValue,
        send action: Action
    ) -> Binding<LocalValue> {
        Binding(
            get: { get(self.value) },
            set: { _ in self.send(action) }
        )
    }
    
    public func binding<LocalValue>(
        get: @escaping (Value) -> LocalValue,
        send toAction: @escaping (LocalValue) -> Action
    ) -> Binding<LocalValue> {
        Binding(
            get: { get(self.value) },
            set: { self.send(toAction($0)) }
        )
    }
}

extension Store where Value: Equatable {
    public var view: ViewStore<Value, Action> {
        self.view(removeDuplicated: ==)
    }
}

extension Store {
    public func view(removeDuplicated predicate: @escaping (Value, Value) -> Bool) -> ViewStore<Value, Action> {
        let viewStore = ViewStore(initialValue: self.value, send: self.send)
        
        viewStore.cancellable = self.$value
            .removeDuplicates(by: predicate)
            .sink(receiveValue: { [weak viewStore] value in
                viewStore?.value = value
            })
        
        return viewStore
    }
}

public final class Store<Value, Action>/*: ObservableObject*/ {
    private let reducer: Reducer<Value, Action, Any>
    private let environment: Any
    @Published private var value: Value
    private var effectCancellables: [UUID: AnyCancellable] = [:]
    private var viewCancellable: Cancellable?
    
    public init<Environment>(
        initialValue: Value,
        reducer: Reducer<Value, Action, Environment>,
        environment: Environment) {
        self.value = initialValue
            self.reducer = .init { value, action, environment in
                reducer(&value, action, environment as! Environment)
            }
        self.environment = environment
    }
    
    private func send(_ action: Action) {
        let effects = self.reducer(&self.value, action, self.environment)
        var didComplete = false
        effects.forEach { effect in
            let uuid = UUID()
            let effectCancellable = effect.sink(
                receiveCompletion: { [weak self] _ in
                    didComplete = true
                    self?.effectCancellables[uuid] = nil
                },
                receiveValue: { [weak self] in self?.send($0) }
            )
            if !didComplete {
                self.effectCancellables[uuid] = effectCancellable
            }
        }
        
    }
    
    public func scope<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: toLocalValue(self.value),
            reducer: .init { localValue, localAction, _ in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
                return []
            },
            environment: self.environment
        )
        localStore.viewCancellable = self.$value
            .map(toLocalValue)
        //      .removeDuplicates()
            .sink { [weak localStore] newValue in
                localStore?.value = newValue
            }
        return localStore
    }
}

extension Reducer {
    public func callAsFunction(
        _ value: inout Value,
        _ action: Action,
        _ environment: Environment
    ) -> [Effect<Action>] {
        self.reducer(&value, action, environment)
    }
}

extension Effect {
    public static func fireAndForget(work: @escaping () -> Void) -> Effect {
        return Deferred { () -> Empty<Output, Never> in
            work()
            return Empty(completeImmediately: true)
        }
        .eraseToEffect()
    }
}


extension Effect {
    public static func sync(work: @escaping () -> Output) -> Effect {
        return Deferred {
            Just(work())
        }.eraseToEffect()
    }
}
