//
//  NewsFeedViewControllerTests.swift
//  CleanNewsiOSTests
//
//  Created by Fernando Putallaz on 07/03/2023.
//

import XCTest
import UIKit
import CleanNewsFramework

final class NewsFeedViewController: UIViewController {
    private var loader: NewsLoader?

    convenience init(loader: NewsLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loader?.load { _ in }
    }
}

final class NewsFeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NewsFeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = NewsFeedViewController(loader: loader)
        
        checkForMemoryLeaks(loader, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }

    class LoaderSpy: NewsLoader {
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (NewsLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}
