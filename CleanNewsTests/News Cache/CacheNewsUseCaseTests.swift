//
//  CacheNewsUseCaseTests.swift
//  CleanNewsTests
//
//  Created by Fernando Putallaz on 03/11/2022.
//

import XCTest

class LocalNewsLoader {
   init(store: NewsStore) {
       
    }
}

class NewsStore {
    var deleteCachedNewsCallCount = 0
}

class CacheNewsUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = NewsStore()
        _ = LocalNewsLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedNewsCallCount, 0)
    }
}
