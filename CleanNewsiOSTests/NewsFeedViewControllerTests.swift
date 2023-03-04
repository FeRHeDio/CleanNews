//
//  NewsFeedViewControllerTests.swift
//  CleanNewsiOSTests
//
//  Created by Fernando Putallaz on 04/03/2023.
//

import XCTest

final class NewsFeedViewController {
    init(loader: NewsFeedViewControllerTests.LoaderSpy) {
        
    }
}

final class NewsFeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = NewsFeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
        // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
    
    
        //    func testPerformanceExample() throws {
        //        // This is an example of a performance test case.
        //        self.measure {
        //            // Put the code you want to measure the time of here.
        //        }
        //    }
    
}
