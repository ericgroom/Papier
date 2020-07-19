//
//  FromResultTests.swift
//  Tests iOS
//
//  Created by Eric Groom on 7/19/20.
//

import XCTest
import Combine
@testable import Papier

class FromResultTests: XCTestCase {
    
    var bag: Set<AnyCancellable>!

    override func setUpWithError() throws {
        bag = Set()
    }

    func testSuccessAsEvent() {
        let result: Result<Void, Never> = .success(())
        let succeedsExpectation = expectation(description: "Should emit void value")
        FromResult(result)
            .sink { _ in
                succeedsExpectation.fulfill()
            }
            .store(in: &bag)
        wait(for: [succeedsExpectation], timeout: 0.1)
    }
    
    fileprivate enum MockError: Error { case fail }
    
    func testFailureAsError() {
        let mockError = MockError.fail
        let result: Result<Void, MockError> = .failure(mockError)
        let failsExpectation = expectation(description: "Should emit void value")
        FromResult(result)
            .sink(receiveCompletion: { completion in
                if
                    case let .failure(error) = completion,
                    error == mockError
                {
                    failsExpectation.fulfill()
                }
            }, receiveValue: { _ in
                XCTFail("Shouldn't emit any value")
            })
            .store(in: &bag)
        wait(for: [failsExpectation], timeout: 0.1)
    }
}
