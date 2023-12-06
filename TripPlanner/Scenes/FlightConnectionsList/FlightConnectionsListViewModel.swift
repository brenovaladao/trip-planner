//
//  FlightConnectionsListViewModel.swift
//  TripPlanner
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation

@MainActor
public protocol FlightConnectionsListViewModeling: ObservableObject {}

final public class FlightConnectionsListViewModel: FlightConnectionsListViewModeling {
    public init() {}
}
