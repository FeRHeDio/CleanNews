//
//  CacheFeedImageDataUseCaseTests.swift
//  CleanNewsFrameworkTests
//
//  Created by Fernando Putallaz on 13/04/2023.
//

import XCTest
import CleanNewsFramework

final class CacheFeedImageDataUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessagesStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
    }
    
    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        checkForMemoryLeaks(store, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }

}
