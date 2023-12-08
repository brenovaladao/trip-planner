//
//  CityAnnotation.swift
//  TripPlanner
//
//  Created by Breno Valadão on 08/12/23.
//

import MapKit

public struct CityAnnotation: Identifiable {
    let name: String
    let coordinates: CLLocationCoordinate2D
    
    public var id: String {
        name + coordinates.latitude.description + coordinates.longitude.description
    }
}

extension CityAnnotation: Equatable {
    public static func == (lhs: CityAnnotation, rhs: CityAnnotation) -> Bool {
        lhs.id == rhs.id
    }
}
