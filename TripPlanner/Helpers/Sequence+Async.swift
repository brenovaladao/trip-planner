//
//  Sequence+Async.swift
//  TripPlanner
//
//  Created by Breno Valadão on 09/12/23.
//

import Foundation

public extension Sequence {
    func asyncForEach(_ operation: @Sendable (Element) async throws -> Void) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}
