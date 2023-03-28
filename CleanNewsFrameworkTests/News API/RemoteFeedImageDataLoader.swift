//
//  RemoteFeedImageDataLoader.swift
//  CleanNewsFrameworkTests
//
//  Created by Fernando Putallaz on 28/03/2023.
//

import XCTest
import CleanNewsFramework

class RemoteFeedImageDataLoader {
    init(client: Any) {
        
    }
}

class RemotFeedImageDataLoader: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        checkForMemoryLeaks(sut, file: file, line: line)
        checkForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private class HTTPClientSpy {
        var requestedURLs = [URL]()
    }
    
}


