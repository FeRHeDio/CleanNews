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
        let loader = LoaderSpy()
        _ = NewsFeedViewController(loader: loader)

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let sut = NewsFeedViewController(loader: loader)

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

        // MARK: - Helpers

    class LoaderSpy: NewsLoader {
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (NewsLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}
