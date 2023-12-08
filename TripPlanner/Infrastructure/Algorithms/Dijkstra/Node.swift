//
//  Node.swift
//  TripPlanner
//
//  Created by Breno Valadão on 08/12/23.
//

import Foundation

public protocol Node: AnyObject {
    var visited: Bool { get set }
    var neighbors: [Neighbor] { get set }
}
