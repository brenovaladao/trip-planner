//
//  Route+DisplayValue.swift
//  TripPlanner
//
//  Created by Breno Valadão on 08/12/23.
//

import Foundation

public extension Route {
    var displayValue: String {
        """
        Price: \(price)
        > \(cities.map { $0.name }.joined(separator: " > "))
        """
    }
    
    var cityAnnotations: [CityAnnotation] {
        cities.map {
            CityAnnotation(
                name: $0.name,
                coordinates: $0.coordinates.asCCLocationCoordinate2D
            )
        }
    }
}
