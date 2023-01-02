//
//  NewsFeedViewControllerTests.swift
//  CleanNewsiOSTests
//
//  Created by Fernando Putallaz on 02/01/2023.
//

import XCTest
import UIKit

final class NewsFeedViewController: UIViewController {
    private var loader: NewsFeedViewControllerTests.LoaderSpy?
    
    convenience init(loader: NewsFeedViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load()
    }
    
}

final class NewsFeedViewControllerTests: XCTestCase {
     
    func test_init_doedNotLoadNewsFeed() {
        let loader = LoaderSpy()
        _ = NewsFeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsNewsFeed() {
        let loader = LoaderSpy()
        let sut = NewsFeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    //MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
        
        func load() {
            loadCallCount += 1
        }
    }
}
