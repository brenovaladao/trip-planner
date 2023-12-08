//
//  Coordinate+CLLocationCoordinate2D.swift
//  TripPlanner
//
//  Created by Breno Valadão on 08/12/23.
//

import MapKit

extension Coordinate {
    var asCCLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}
