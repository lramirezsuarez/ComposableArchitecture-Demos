//
//  PrimeAlert.swift
//  PrimeAlert
//
//  Created by Luis Alejandro Ramirez Suarez on 14/10/22.
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
        return "The \(PrimeAlert.ordinal(self.n)) prime is \(self.prime)"
    }
    
    public static func ordinal(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(for: n) ?? ""
    }
}
