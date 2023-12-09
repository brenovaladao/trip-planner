//
//  CityNamesAutoCompleting.swift
//  TripPlanner
//
//  Created by Breno Valadão on 09/12/23.
//

import Foundation

public protocol CityNamesAutoCompleting: Sendable {
    func search(for query: String) async -> [String]
}
