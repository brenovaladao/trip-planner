//
//  RemoteConnectionsLoaderTests.swift
//  TripPlannerTests
//
//  Created by Breno Valadão on 06/12/23.
//

import XCTest
import TripPlanner

final class RemoteConnectionsLoaderTests: XCTestCase {
    func test_fetchConnections_successOnValidData() async throws {
        let url = anyURL()
        let flightConnection = aFligthConnection()
        
        let sut = makeSUT(url: url)
        
        let data = makeConnectionsJSON(
            [makeDictionaryRepresentation(flightConnection)]
        )
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        let connections = try await sut.fetchConnections()
        
        XCTAssertEqual(connections, [flightConnection])
    }
}

private extension RemoteConnectionsLoaderTests {
    func makeSUT(url: URL) -> RemoteConnectionsLoader {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        
        let sut = RemoteConnectionsLoader(
            urlSession: urlSession,
            endpoint: url
        )
        
        return sut
    }
}
