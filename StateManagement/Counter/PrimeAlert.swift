//
//  PrimeAlert.swift
//  StateManagement
//
//  Created by Luis Alejandro Ramirez Suarez on 18/08/22.
//

public struct PrimeAlert: Identifiable, Equatable {
    public let n: Int
    public let prime: Int
    public var id: Int { self.prime }
    
    public init(n: Int, prime: Int) {
        self.n = n
        self.prime = prime
    }
    
    public var title: String {
        return "The \(ordinal(self.n)) prime is \(self.prime)"
    }
}
