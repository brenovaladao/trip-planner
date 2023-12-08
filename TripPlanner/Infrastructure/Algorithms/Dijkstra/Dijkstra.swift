//
//  Dijkstra.swift
//  TripPlanner
//
//  Created by Breno Valadão on 08/12/23.
//

import Foundation

/// Provides the logic for finding the shortest path based on a price (weight) property
/// References:
/// - https://www.kodeco.com/279-swift-algorithm-club-swift-dijkstra-s-algorithm
/// - https://en.wikipedia.org/wiki/Dijkstra's_algorithm
/// -
public enum Dijkstra {
    static func shortestPath(departure: Node, destination: Node) -> Path? {
        var frontier: [Path] = [] {
            didSet { frontier.sort { $0.cumulativePrice < $1.cumulativePrice } }
        }
        
        frontier.append(Path(to: departure))
        
        while !frontier.isEmpty {
            let cheapestPathInFrontier = frontier.removeFirst()
            guard !cheapestPathInFrontier.node.visited else { continue }
            
            if cheapestPathInFrontier.node === destination {
                return cheapestPathInFrontier
            }
            
            cheapestPathInFrontier.node.visited = true
            
            for connection in cheapestPathInFrontier.node.neighbors where !connection.to.visited {
                let path = Path(to: connection.to, via: connection, previousPath: cheapestPathInFrontier)
                frontier.append(path)
            }
        }
        
        return nil
    }
}
