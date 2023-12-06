//
//  XCTestCase+CombineConvenience.swift
//  TripPlannerTests
//
//  Created by Breno Valadão on 06/12/23.
//

import Combine
import XCTest

public extension Publisher where Output: Equatable {
    func assertOutput(
        matches: [Output]?,
        expectation: XCTestExpectation,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> AnyCancellable {
        guard var expectedValues = matches else {
            expectation.fulfill()
            return sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in }
            )
        }
        
        return sink(
            receiveCompletion: { _ in },
            receiveValue: { value in
                guard let expectedValue = expectedValues.first else {
                    XCTFail("The publisher emitted more values than expected", file: file, line: line)
                    return
                }

                guard expectedValue == value else {
                    return XCTFail(
                        "Expected received value \(value) to match first expected value \(expectedValue)",
                        file: file,
                        line: line
                    )
                }

                expectedValues = Array(expectedValues.dropFirst())

                if expectedValues.isEmpty {
                    expectation.fulfill()
                }
            }
        )
    }
}
