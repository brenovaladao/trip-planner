//
//  Path.swift
//  TripPlanner
//
//  Created by Breno Valadão on 08/12/23.
//

import Foundation

public final class Path {
    public let cumulativePrice: Decimal
    public let node: Node
    public let previousPath: Path?
    
    public init(to node: Node, via neighbor: Neighbor? = nil, previousPath path: Path? = nil) {
        if let previousPath = path,
           let toNeighbor = neighbor {
            cumulativePrice = toNeighbor.price + previousPath.cumulativePrice
        } else {
            cumulativePrice = 0
        }
        
        self.node = node
        previousPath = path
    }
}

extension Path {
    var lightPath: [Node] {
        var array: [Node] = [node]
        
        var iterativePath = self
        while let path = iterativePath.previousPath {
            array.append(path.node)
            iterativePath = path
        }

        return array.reversed()
    }
}
