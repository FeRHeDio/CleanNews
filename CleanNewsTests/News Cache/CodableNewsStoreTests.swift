//
//  CodableNewsStoreTests.swift
//  CleanNewsTests
//
//  Created by Fernando Putallaz on 22/11/2022.
//

import XCTest
import CleanNews

class CodableNewsStore {
    func retrieve(completion: @escaping NewsStore.RetrievalCompletion) {
        completion(.empty)
    }
}

final class CodableNewsStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableNewsStore()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
                
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
