//
//  FlightNode.swift
//  TripPlanner
//
//  Created by Breno Valadão on 08/12/23.
//

import Foundation

final class FlightNode: Node {
    let city: String
    var visited = false
    var neighbors: [Neighbor] = []
    
    init(city: String) {
        self.city = city
    }
}
