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
        
        setupEmptyState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let items = uniqueItems().local
        let timestamp = Date()
        
        insert((items, timestamp), to: sut)
        
        expect(sut, toRetrieve: .found(items: items, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let items = uniqueItems().local
        let timestamp = Date()
        
        insert((items, timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .found(items: items, timestamp: timestamp))
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableNewsStore {
        let sut = CodableNewsStore(storeURL: testSepecificStoreURL())
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func insert(_ cache: (news: [LocalNewsItem], timestamp: Date), to sut: CodableNewsStore) {
        let exp = expectation(description: "Wait for cache retrieval")
        sut.insert(cache.news, timestamp: cache.timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected the feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableNewsStore, toRetrieveTwice expectedResult: RetrieveCachedNewsResult, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: CodableNewsStore, toRetrieve expectedResult: RetrieveCachedNewsResult, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrieveResult in
            switch (expectedResult, retrieveResult) {
            case (.empty, .empty):
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

    private func setupEmptyState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSepecificStoreURL())
    }
    
    private func testSepecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
