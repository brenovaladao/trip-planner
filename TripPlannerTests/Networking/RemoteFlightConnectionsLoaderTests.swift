//
//  RemoteFlightConnectionsLoaderTests.swift
//  TripPlannerTests
//
//  Created by Breno Valadão on 06/12/23.
//

import XCTest
import TripPlanner

final class RemoteFlightConnectionsLoaderTests: XCTestCase {
    func test_fetchConnections_successOnValidData() async throws {
        let flightConnection = aFligthConnection()
        let sut = makeSUT()
        let data = makeConnectionsJSON(
            [makeDictionaryRepresentation(flightConnection)]
        )
        setURLProtocolRequestHandler(data: data)
        
        let connections = try await sut.fetchConnections()
        
        XCTAssertEqual(connections, [flightConnection])
    }
    
    func test_fetchConnections_successOnEmptyData() async throws {
        let sut = makeSUT()
        let data = makeConnectionsJSON([])
        setURLProtocolRequestHandler(data: data)
        
        let connections = try await sut.fetchConnections()
        
        XCTAssertTrue(connections.isEmpty)
    }
    
    func test_fetchConnections_errorOnInvalidData() async {
        let sut = makeSUT()
        let data = invalidJSON()
        setURLProtocolRequestHandler(data: data)
        
        do {
            _ = try await sut.fetchConnections()
            XCTFail("Should fail with invalid data error")
        } catch {
            XCTAssertEqual((error as? FlightConnectionsMapper.Error), .invalidData)
        }
    }
    
    func test_fetchConnections_errorOnInvalidStatusCode() async {
        let sut = makeSUT()
        let data = makeConnectionsJSON([])
        setURLProtocolRequestHandler(statusCode: 401, data: data)
        
        do {
            _ = try await sut.fetchConnections()
            XCTFail("Should fail with invalid data error")
        } catch {
            XCTAssertEqual((error as? FlightConnectionsMapper.Error), .invalidData)
        }
    }
}

private extension RemoteFlightConnectionsLoaderTests {
    func makeSUT() -> RemoteFlightConnectionsLoader {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        
        let sut = RemoteFlightConnectionsLoader(
            urlSession: urlSession,
            endpoint: anyURL()
        )
        
        return sut
    }
    
    func setURLProtocolRequestHandler(statusCode: Int = 200, data: Data) {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
    }
}
