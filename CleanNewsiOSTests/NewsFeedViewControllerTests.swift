//
//  NewsFeedViewControllerTests.swift
//  CleanNewsiOSTests
//
//  Created by Fernando Putallaz on 07/03/2023.
//

import XCTest
import UIKit
import CleanNewsFramework
import CleanNewsiOS

final class NewsFeedViewControllerTests: XCTestCase {
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a load")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiated a reload")
        
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator while user initiated loading is completed")
    }
    
    func test_loadFeedCompletion_rendersSuccesfullyLoadedFeed() {
        let newsItem0 = makeNewsItem(title: "Some title", description: "some description")
        let newsItem1 = makeNewsItem(title: "A new title", description: "A new description")
        let newsItem2 = makeNewsItem(title: "", description: "some description")
        let newsItem3 = makeNewsItem(title: "Ugly title", description: "")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [newsItem0], at: 0)
        assertThat(sut, isRendering: [newsItem0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [newsItem0, newsItem1, newsItem2, newsItem3], at: 1)
        assertThat(sut, isRendering: [newsItem0, newsItem1, newsItem2, newsItem3])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NewsFeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = NewsFeedViewController(loader: loader)
        
        checkForMemoryLeaks(loader, file: file, line: line)
        checkForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func assertThat(_ sut: NewsFeedViewController, isRendering newsFeed: [NewsItem], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedNewsViews() == newsFeed.count else {
            return XCTFail("Expected \(newsFeed.count) newsItems, got \(sut.numberOfRenderedNewsViews()) instead")
        }
        
        newsFeed.enumerated().forEach { index, item in
            assertThat(sut, hasViewConfiguredFor: item , at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: NewsFeedViewController, hasViewConfiguredFor newsItem: NewsItem, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.newsFeedView(at: index)
        
        guard let cell = view as? NewsItemCell else {
            return XCTFail("Expected \(NewsItemCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.titleText, newsItem.title, "Expected title text to be \(String(describing: newsItem.title)) for index \(index)", file: file, line: line)
        XCTAssertEqual(cell.descriptionText, newsItem.description, "Expected description text to be \(String(describing: newsItem.description)) for index \(index)", file: file, line: line)
    }
    
    private func makeNewsItem(title: String = "", description: String = "", content: String = "") -> NewsItem {
        NewsItem(id: UUID(), title: title, description: description, content: content)
    }

    class LoaderSpy: NewsLoader {
        private var completions = [(NewsLoader.Result) -> Void]()
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (NewsLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(with newsFeed: [NewsItem] = [], at index: Int) {
            completions[index](.success(newsFeed))
        }
    }
}

private extension NewsFeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedNewsViews() -> Int {
        tableView.numberOfRows(inSection: newsSection)
    }
    
    func newsFeedView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: newsSection)
        
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var newsSection: Int {
        0
    }
}

private extension NewsItemCell {
    var titleText: String? {
        titleLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
