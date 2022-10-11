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

public typealias Reducer<Value, Action, Environment> = (inout Value, Action, Environment) -> [Effect<Action>]

public final class ViewStore<Value>: ObservableObject {
    @Published public fileprivate(set) var value: Value
    fileprivate var cancellable: Cancellable?
    
    public init(initialValue value: Value) {
        self.value = value
    }
}

extension Store where Value: Equatable {
    public var view: ViewStore<Value> {
        self.view(removeDuplicated: ==)
    }
}

extension Store {
    public func view(removeDuplicated predicate: @escaping (Value, Value) -> Bool) -> ViewStore<Value> {
        let viewStore = ViewStore(initialValue: self.value)
        
        viewStore.cancellable = self.$value
            .removeDuplicates(by: predicate)
            .sink(receiveValue: { [weak viewStore] value in
                viewStore?.value = value
                self
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
        reducer: @escaping Reducer<Value, Action, Environment>,
        environment: Environment) {
        self.value = initialValue
            self.reducer = { value, action, environment in
                reducer(&value, action, environment as! Environment)
            }
        self.environment = environment
    }
    
    public func send(_ action: Action) {
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
            reducer: { localValue, localAction, _ in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
                return []
            },
            environment: self.environment
        )
        localStore.viewCancellable = self.$value.sink { [weak localStore] newValue in
            localStore?.value = toLocalValue(newValue)
        }
    
        return localStore
    }
}

public func combine<Value, Action, Environment>(
    _ reducers: Reducer<Value, Action, Environment>...
) -> Reducer<Value, Action, Environment> {
    return { value, action, environment in
        let effects = reducers.flatMap { $0(&value, action, environment) }
        return effects
    }
}

public func pullback<GlobalValue, LocalValue, GlobalAction, LocalAction, GlobalEnvironment, LocalEnvironment>(
    _ reducer: @escaping Reducer<LocalValue, LocalAction, LocalEnvironment>,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>,
    environment: @escaping (GlobalEnvironment) -> LocalEnvironment
) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
    return { globalValue, globalAction, globalEnvironment in
        guard let localAction = globalAction[keyPath: action] else { return [] }
        let localEffects = reducer(&globalValue[keyPath: value], localAction, environment(globalEnvironment))
        return localEffects.map { localEffect in
            localEffect.map { localAction -> GlobalAction in
                var globalAction = globalAction
                globalAction[keyPath: action] = localAction
                return globalAction
                
            }
            .eraseToEffect()
//            Effect { callback in
//                localEffect.run { localAction in
//                    var globalAction = globalAction
//                    globalAction[keyPath: action] = localAction
//                    callback(globalAction)
//                }
//            }
        }
    }
}

public func logging<Value, Action, Environment>(
    _ reducer: @escaping Reducer<Value, Action, Environment>
) -> Reducer<Value, Action, Environment> {
    return { value, action, environment in
        let effects = reducer(&value, action, environment)
        let newValue = value
        return [.fireAndForget {
            print("Action: \(action)")
            print("Value: ")
            dump(newValue)
            print("----")
        }] + effects
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
