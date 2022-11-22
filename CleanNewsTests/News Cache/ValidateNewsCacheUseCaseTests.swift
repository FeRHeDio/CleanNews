//
//  ValidateNewsCacheUseCaseTests.swift
//  CleanNewsTests
//
//  Created by Fernando Putallaz on 19/11/2022.
//

import XCTest
import CleanNews

final class ValidateNewsCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedNews])
    }
    
    func test_validateCache_doesNotdeletesCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeletesLessThanSevenDaysOldCache() {
        let news = uniqueItems()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: news.local, timestamp: lessThanSevenDaysOldTimeStamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesSevenDaysOldCache() {
        let news = uniqueItems()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: news.local, timestamp: sevenDaysOldTimeStamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedNews])
    }
    
    func test_validateCache_deletesMoreThanSevenDaysOldCache() {
        let news = uniqueItems()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimeStamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: news.local, timestamp: moreThanSevenDaysOldTimeStamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedNews])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        
        let store = NewsStoreSpy()
        var sut: LocalNewsLoader? = LocalNewsLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
        
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalNewsLoader, store: NewsStoreSpy) {
        let store = NewsStoreSpy()
        let sut = LocalNewsLoader(store: store, currentDate: currentDate)
        
        checkForMemoryLeaks(store, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
}
