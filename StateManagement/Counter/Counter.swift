//
//  Counter.swift
//  Counter
//
//  Created by Luis Alejandro Ramirez Suarez on 29/08/22.
//

public enum CounterAction {
    case decrementTap
    case incrementTap
}


public func counterReducer(state: inout Int, action: CounterAction) {
    switch action {
    case .decrementTap:
        state -= 1
    case .incrementTap:
        state += 1
    }
}
