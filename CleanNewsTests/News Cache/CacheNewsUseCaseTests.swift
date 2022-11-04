//
//  CacheNewsUseCaseTests.swift
//  CleanNewsTests
//
//  Created by Fernando Putallaz on 03/11/2022.
//

import XCTest
import CleanNews

class LocalNewsLoader {
    let store: NewsStore
    
    init(store: NewsStore) {
        self.store = store
    }
    
    func save(_ items: [NewsItem]) {
        store.deleteCachedNews()
    }
}

class NewsStore {
    var deleteCachedNewsCallCount = 0
    
    func deleteCachedNews() {
        deleteCachedNewsCallCount += 1
    }
}

class CacheNewsUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = NewsStore()
        _ = LocalNewsLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedNewsCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let store = NewsStore()
        let sut = LocalNewsLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedNewsCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func uniqueItem() -> NewsItem {
        NewsItem(title: "some title", description: "some descri", content: "some content")
    }
}
