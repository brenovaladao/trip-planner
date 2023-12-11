//
//  FlightConnectionsServiceTests.swift
//  TripPlannerTests
//
//  Created by Breno Valadão on 06/12/23.
//

import XCTest
import TripPlanner

final class FlightConnectionsServiceTests: XCTestCase {
    func test_fetchConnections_successOnValidData() async throws {
        let flightConnection = aFligthConnection()
        let sut = makeSUT()
        let data = makeFlightConnectionsJSON(
            [makeDictionaryRepresentation(flightConnection)]
        )
        setURLProtocolRequestHandler(data: data)
        
        let connections = try await sut.fetchConnections()
        
        XCTAssertEqual(connections, [flightConnection])
    }
    
    func test_fetchConnections_successOnEmptyData() async throws {
        let sut = makeSUT()
        let data = makeFlightConnectionsJSON([])
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
        let data = makeFlightConnectionsJSON([])
        setURLProtocolRequestHandler(statusCode: 401, data: data)
        
        do {
            _ = try await sut.fetchConnections()
            XCTFail("Should fail with invalid data error")
        } catch {
            XCTAssertEqual((error as? FlightConnectionsMapper.Error), .invalidData)
        }
    }
    
    func test_fetchConnections_errorOnNonHTTPURLResponse() async {
        let sut = makeSUT()
        let data = makeFlightConnectionsJSON([])
        
        URLProtocolMock.requestHandler = { request in
            let nonHTTPURLResponse = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
            return (nonHTTPURLResponse, data)
        }
        
        do {
            _ = try await sut.fetchConnections()
            XCTFail("Should fail with invalid data error")
        } catch is FlightConnectionsService.UnexpectedValuesError {
        } catch {
            XCTFail("Should have failed with UnexpectedValuesError error")
        }
    }
}

private extension FlightConnectionsServiceTests {
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FlightConnectionsService {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolMock.self]
        let urlSession = URLSession(configuration: configuration)
        
        let sut = FlightConnectionsService(
            urlSession: urlSession,
            endpoint: anyURL()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    func setURLProtocolRequestHandler(statusCode: Int = 200, data: Data) {
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
    }
}
