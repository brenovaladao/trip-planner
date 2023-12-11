//
//  ShortestPathFinding.swift
//  TripPlanner
//
//  Created by Breno Valadão on 11/12/23.
//

import Foundation

public protocol ShortestPathFinding: Sendable {
    func shortestPath(departure: Node, destination: Node) -> Path?
}
