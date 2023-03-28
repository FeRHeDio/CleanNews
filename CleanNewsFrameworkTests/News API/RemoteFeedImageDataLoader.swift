//
//  RemoteFeedImageDataLoader.swift
//  CleanNewsFrameworkTests
//
//  Created by Fernando Putallaz on 28/03/2023.
//

import XCTest
import CleanNewsFramework

class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (Any) -> Void) {
        client.get(from: url) { _ in }
    }
}

class RemotFeedImageDataLoader: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestDataFromURL() {
        let url = URL(string: "https://a-given-url")!
        let (sut, client) = makeSUT(url: url)
        
        sut.loadImageData(from: url, completion: { _ in })
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedURLs.append(url)
        }
    }
}


