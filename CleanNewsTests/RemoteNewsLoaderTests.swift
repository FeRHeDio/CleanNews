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
        
        expect(sut, completeWithError: .connectivity) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500].enumerated()
        
        samples.forEach { index,code in
            expect(sut, completeWithError: .invalidData) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        
        expect(sut, completeWithError: .invalidData) {
            let invalidData = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidData)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJsonList() {
        let (sut, client) = makeSUT()
        
        var capturedResults = [RemoteNewsLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        let emptyJsonList = Data("{\"articles\": []}".utf8)
        client.complete(withStatusCode: 200, data: emptyJsonList)
        
        XCTAssertEqual(capturedResults, [.success([])])
    }
    
     
    
    //MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "a_Super_URL")!) -> (sut: RemoteNewsLoader, client: HTTPClientSpy)  {
        let client = HTTPClientSpy()
        let sut = RemoteNewsLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteNewsLoader, completeWithError error: RemoteNewsLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        var capturedResults = [RemoteNewsLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [.failure(error)], file: file, line: line)
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
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
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
