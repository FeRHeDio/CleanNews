//
//  NewsFeedViewControllerTests.swift
//  CleanNewsiOSTests
//
//  Created by Fernando Putallaz on 02/01/2023.
//

import XCTest

final class NewsFeedViewController {
    init(loader: NewsFeedViewControllerTests.LoaderSpy) {
        
    }
}

final class NewsFeedViewControllerTests: XCTestCase {
     
    func test_init_doedNotLoadNewsFeed() {
        let loader = LoaderSpy()
        _ = NewsFeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    //MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
}
