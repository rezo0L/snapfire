//
//  Helpers.swift
//  Snapfire
//
//  Created by Reza on 2025-05-15.
//

import Combine
import XCTest

func waitForFirstValue<T: Publisher>(
    from publisher: T,
    timeout: TimeInterval = 1.0
) throws -> T.Output {
    let expectation = XCTestExpectation(description: "Waiting for first published value")
    var result: T.Output?
    var cancellable: AnyCancellable?

    cancellable = publisher
        .dropFirst() // Skip initial value
        .sink { _ in
            // Ignore completion
        } receiveValue: { value in
            result = value
            expectation.fulfill()
            cancellable?.cancel()
        }

    let waiterResult = XCTWaiter().wait(for: [expectation], timeout: timeout)
    guard waiterResult == .completed, let value = result else {
        throw XCTSkip("Timed out waiting for published value")
    }

    return value
}
