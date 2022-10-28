//
//  RemoteNewsLoaderTests.swift
//  CleanNewsTests
//
//  Created by Fernando Putallaz on 26/09/2022.
//

import XCTest
import CleanNews

final class RemoteNewsLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestFromURLData() {
        let url = URL(string: "some_Super_URL")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestFromURLDataTwice() {
        let url = URL(string: "some_Super_URL")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, completeWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500].enumerated()
        
        samples.forEach { index,code in
            expect(sut, completeWith: .failure(.invalidData)) {
                let json = makeItemsJson([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        
        expect(sut, completeWith: .failure(.invalidData)) {
            let invalidData = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidData)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJsonList() {
        let (sut, client) = makeSUT()
        
        expect(sut, completeWith: .success([])) {
            let emptyJsonList = makeItemsJson([])
            client.complete(withStatusCode: 200, data: emptyJsonList)
        }
    }
    
    //Happy Path
    
    func test_load_deliversItemsOn200HTTPResponseWithJsonItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            title: "some news title",
            description: "Some description",
            content: "some content for the first article"
        )
        
        let item2 = makeItem(
            title: "Another title",
            description: "Another description for second article",
            content: "More content for the second article"
        )
     
        let items = [item1.model, item2.model]
        
        expect(sut, completeWith: .success(items)) {
            let json = makeItemsJson([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        
        var sut: RemoteNewsLoader? = RemoteNewsLoader(url: url, client: client)
        var capturedResults = [RemoteNewsLoader.Result]()
        
        sut?.load { capturedResults.append($0) }
     
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJson([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    //MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "a_Super_URL")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteNewsLoader, client: HTTPClientSpy)  {
        let client = HTTPClientSpy()
        let sut = RemoteNewsLoader(url: url, client: client)
        
        checkForMemoryLeaks(client, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private func checkForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private func expect(_ sut: RemoteNewsLoader, completeWith expectedResult: RemoteNewsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
                
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receievedErrors), .failure(expectedErrors)):
                XCTAssertEqual(receievedErrors, expectedErrors, file: file, line: line)
                
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult)")
            }
        
            exp.fulfill()
            
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeItem(title: String, description: String, content: String) -> (model: NewsItem, json: [String: Any]) {
        
        let item = NewsItem(
            title: title,
            description: description,
            content: content
        )
        
        let json = [
            "title": title,
            "description": description,
            "content": content
        ]
        
        return (item, json)
    }
    
    private func makeItemsJson(_ items: [[String: Any]]) -> Data {
        let json = ["articles": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
}
