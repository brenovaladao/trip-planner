//
//  Helpers.swift
//  TripPlannerTests
//
//  Created by Breno Valadão on 06/12/23.
//

import Foundation
import TripPlanner

func anyURL() -> URL {
    URL(string: "any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func invalidJSON() -> Data {
    Data("invalid json".utf8)
}

func aFligthConnection() -> FlightConnection {
    makeFlightConnection()
}

func anotherFlightConnection() -> FlightConnection {
    makeFlightConnection(
        from: "Cape Town",
        to: "Porto",
        price: 700,
        fromLat: -33.9,
        fromLong: 18.4,
        toLat: 51.5,
        toLong: -0.2
    )
}

func makeFlightConnection(
    from: String = "London",
    to: String = "Cape Town",
    price: Decimal = 200,
    fromLat: Double = 51.5,
    fromLong: Double = -0.2,
    toLat: Double = 35.6,
    toLong: Double = 139.8
) -> FlightConnection {
    FlightConnection(
        from: from,
        to: to,
        price: price,
        coordinates: CoordinatesInfo(
            from: Coordinate(
                lat: fromLat,
                long: fromLong
            ),
            to: Coordinate(
                lat: toLat,
                long: toLong
            )
        )
    )
}

func makeDictionaryRepresentation(_ flightConnection: FlightConnection) -> [String: Any] {
    [
        "from": flightConnection.from,
        "to": flightConnection.to,
        "price": flightConnection.price,
        "coordinates": [
            "from": [
                "lat": flightConnection.coordinates.from.lat,
                "long": flightConnection.coordinates.from.long
            ],
            "to": [
                "lat": flightConnection.coordinates.to.lat,
                "long": flightConnection.coordinates.to.long
            ]
        ]
    ]
}

func makeConnectionsJSON(_ items: [[String: Any]]) -> Data {
    let json = ["connections": items]
    return try! JSONSerialization.data(withJSONObject: json)
}
