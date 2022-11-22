//
//  CodableNewsStoreTests.swift
//  CleanNewsTests
//
//  Created by Fernando Putallaz on 22/11/2022.
//

import XCTest
import CleanNews

class CodableNewsStore {
    private struct Cache: Codable {
        let items: [CodableNewsItem]
        let timestamp: Date
        
        var localNews: [LocalNewsItem] {
            return items.map { $0.local }
        }
    }
    
    private struct CodableNewsItem: Codable {
        private let title: String
        private let description: String
        private let content: String
        
        init(_ item: LocalNewsItem) {
            title = item.title
            description = item.description
            content = item.content
        }
        
        var local: LocalNewsItem {
            return LocalNewsItem(title: title, description: description, content: content)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping NewsStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(items: cache.localNews, timestamp: cache.timestamp))
    }
    
    func insert(_ items: [LocalNewsItem], timestamp: Date, completion: @escaping NewsStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(items: items.map(CodableNewsItem.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        
        completion(nil)
    }
}

final class CodableNewsStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        try? FileManager.default.removeItem(at: testSepecificStoreURL())
    }
    
    override func tearDown() {
        super.tearDown()
        
        try? FileManager.default.removeItem(at: testSepecificStoreURL())
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
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
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                    
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let items = uniqueItems().local
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.insert(items, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected the feed to be inserted successfully")
            
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .found(items: retrieveNews, timestamp: retrievedTimestamp):
                    XCTAssertEqual(retrieveNews, items)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                    
                default:
                    XCTFail("Expected foudn result with news items \(items) and timestamp \(timestamp), received \(retrieveResult) instead")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableNewsStore {
        let sut = CodableNewsStore(storeURL: testSepecificStoreURL())
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func testSepecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
}
