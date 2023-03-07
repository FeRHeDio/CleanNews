//
//  LoadNewsFromCacheUseCaseTests.swift
//  CleanNewsTests
//
//  Created by Fernando Putallaz on 17/11/2022.
//

import XCTest
import CleanNewsFramework

class LoadNewsFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCacheItemsOnNonExpiredCache() {
        let news = uniqueItems()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(news.models)) {
            store.completeRetrieval(with: news.local, timestamp: nonExpiredTimestamp)
        }
    }
    
    func test_load_deliversNoItemsOnCacheExpiration() {
        let news = uniqueItems()
        let fixedCurrentDate = Date()
        let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: news.local, timestamp: expirationTimeStamp)
        }
    }
    
    func test_load_deliversNoItemsOnExpiredCache() {
        let news = uniqueItems()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: news.local, timestamp: expiredTimestamp)
        }
    }

    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let news = uniqueItems()
        let fixedCurrentDate = Date()
        let nonExpiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: news.local, timestamp: nonExpiredTimeStamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnCacheExpiration() {
        let news = uniqueItems()
        let fixedCurrentDate = Date()
        let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: news.local, timestamp: expirationTimeStamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnExpiredCache() {
        let news = uniqueItems()
        let fixedCurrentDate = Date()
        let expiredTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: news.local, timestamp: expiredTimeStamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
        
    func test_load_doesNotDeliversResultAfterSUTHaveBeenDeallocated() {
        let store = NewsStoreSpy()
        var sut: LocalNewsLoader? = LocalNewsLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalNewsLoader.LoadResult]()
        sut?.load { receivedResults.append($0) }
        sut = nil
        
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
        
        
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalNewsLoader, store: NewsStoreSpy) {
        let store = NewsStoreSpy()
        let sut = LocalNewsLoader(store: store, currentDate: currentDate)
        
        checkForMemoryLeaks(store, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    func expect(_ sut: LocalNewsLoader, toCompleteWith expectedResult: LocalNewsLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
            
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), received \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
}
