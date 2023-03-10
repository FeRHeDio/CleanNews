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
        
        XCTAssertEqual(loader.loadNewsFeedCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadNewsFeedCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadNewsFeedCallCount, 2, "Expected another loading request once user initiates a load")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadNewsFeedCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiated a reload")
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
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
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let newsItem0 = makeNewsItem()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [newsItem0], at: 0)
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [newsItem0])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let item0 = makeNewsItem(imageURL: URL(string: "http://url-0.com")!)
        let item1 = makeNewsItem(imageURL: URL(string: "http://url-1.com")!)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item0, item1])
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL], "Expected first image URL request once first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL, item1.imageURL], "Expected second image URL request once second view also becomes visible")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NewsFeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = NewsFeedViewController(newsFeedLoader: loader, imageLoader: loader)
        
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
    
    private func makeNewsItem(title: String = "", description: String = "", imageURL: URL = URL(string: "http://any-url.com")!, content: String = "") -> NewsItem {
        NewsItem(id: UUID(), title: title, description: description, imageURL: imageURL ,content: content)
    }

    class LoaderSpy: NewsLoader, NewsFeedImageDataLoader {
        
        //MARK: - NewsFeedLoader
        
        private var feedRequests = [(NewsLoader.Result) -> Void]()
        
        var loadNewsFeedCallCount: Int {
            feedRequests.count
        }
        
        func load(completion: @escaping (NewsLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with newsFeed: [NewsItem] = [], at index: Int = 0) {
            feedRequests[index](.success(newsFeed))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index](.failure(error))
        }
        
        //MARK: - NewsFeedImageDataLoader
        
        private(set) var loadedImageURLs = [URL]()
        
        func loadImageData(from url: URL) {
            loadedImageURLs.append(url)
        }
    }
}

private extension NewsFeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateFeedImageViewVisible(at index: Int) {
        _ = newsFeedView(at: index)
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
