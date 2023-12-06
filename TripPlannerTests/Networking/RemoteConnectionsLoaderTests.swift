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
    
    func test_fetchConnections_successOnEmptyData() async throws {
        let url = anyURL()
        let sut = makeSUT(url: url)
        
        let data = makeConnectionsJSON([])
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        let connections = try await sut.fetchConnections()
        
        XCTAssertTrue(connections.isEmpty)
    }
    
    func test_fetchConnections_errorOnInvalidData() async {
        let url = anyURL()
        let sut = makeSUT(url: url)
        
        let data = invalidJSON()
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        do {
            _ = try await sut.fetchConnections()
            XCTFail("Should fail with invalid data error")
        } catch {
            XCTAssertEqual((error as? FlightConnectionsMapper.Error), .invalidData)
        }
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
