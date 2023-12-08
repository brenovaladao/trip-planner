//
//  Neighbor.swift
//  TripPlanner
//
//  Created by Breno Valadão on 08/12/23.
//

import Foundation

public final class Neighbor {
    public let to: Node
    public let price: Decimal
    
    public init(to node: Node, price: Decimal) {
        self.to = node
        self.price = price
    }
}
