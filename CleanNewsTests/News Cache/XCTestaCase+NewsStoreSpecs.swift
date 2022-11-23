//
//  XCTestaCase+NewsStoreSpecs.swift
//  CleanNewsTests
//
//  Created by Fernando Putallaz on 23/11/2022.
//

import XCTest
import CleanNews

extension NewsStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (news: [LocalNewsItem], timestamp: Date), to sut: NewsStore) -> Error? {
        let exp = expectation(description: "Wait for cache retrieval")
        var insertionError: Error?
        sut.insert(cache.news, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }

    @discardableResult
    func deleteCache(from sut: NewsStore) -> Error? {
            let exp = expectation(description: "Wait for cache deletion")
            var deletionError: Error?
            sut.deleteCachedNews { receivedDeletionError in
                deletionError = receivedDeletionError
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1.0)
            return deletionError
        }


    func expect(_ sut: NewsStore, toRetrieveTwice expectedResult: RetrieveCachedNewsResult, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    func expect(_ sut: NewsStore, toRetrieve expectedResult: RetrieveCachedNewsResult, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrieveResult in
            switch (expectedResult, retrieveResult) {
            case (.empty, .empty), (.failure, .failure):
                break
                
            case let (.found(expected), .found(retrieved)):
                XCTAssertEqual(retrieved.items, expected.items, file: file, line: line)
                XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrieveResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    
}

