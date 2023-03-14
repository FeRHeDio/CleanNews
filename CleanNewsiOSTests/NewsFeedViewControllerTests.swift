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
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let item0 = makeNewsItem(imageURL: URL(string: "http://url-0.com")!)
        let item1 = makeNewsItem(imageURL: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item0, item1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [item0.imageURL], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [item0.imageURL, item1.imageURL], "Expected two cancelled images URL requests once second image is also not visible anymore")
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [makeNewsItem(), makeNewsItem()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected loading indicator for first view while loading first image completes succesfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [makeNewsItem(), makeNewsItem()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [makeNewsItem(), makeNewsItem()])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action for second view while loading second image")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected no retry action state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected no retry action state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingRetryAction, true, "Expected retry action for second view once second image loading completes with error")
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeNewsItem()])
        
        let view = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expecte no retry action while loading image")
        
        let invalidImageData = Data("Invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loaging completes with invalid image data")
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad1() {
        let item0 = makeNewsItem(imageURL: URL(string: "http://url-0.com")!)
        let item1 = makeNewsItem(imageURL: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item0, item1])
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL, item1.imageURL], "Expected two image URL requests for the two visible views")

        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL, item1.imageURL], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL, item1.imageURL, item0.imageURL], "Expected a third image URL request after first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL, item1.imageURL, item0.imageURL, item1.imageURL], "Expected a fourth image URL request after second view retry action")
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let item0 = makeNewsItem(imageURL: URL(string: "http://url-0.com")!)
        let item1 = makeNewsItem(imageURL: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item0, item1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL until view is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL], "Expected first image URL request once first image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [item0.imageURL, item1.imageURL], "Expected second image URL request once second image is near visible")
    }

    func test_feedImageView_preloadsImageURLWhenNotNearVisible() {
        let item0 = makeNewsItem(imageURL: URL(string: "http://url-0.com")!)
        let item1 = makeNewsItem(imageURL: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [item0, item1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no canceled image URL request until view is not near visible")
        
        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [item0.imageURL], "Expected first canceled image URL request once first image is not near visible anymore")
        
        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [item0.imageURL, item1.imageURL], "Expected second canceled image URL request once second image is not near visible anymore")
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
        
        private struct TaskSpy: NewsFeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequests = [(url: URL, completion: (NewsFeedImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            imageRequests.map { $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (NewsFeedImageDataLoader.Result) -> Void) -> NewsFeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
    }
}

private extension NewsFeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> NewsItemCell? {
        newsFeedView(at: index) as? NewsItemCell
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: newsSection)
        
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: newsSection)
        
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func simulateFeedImageViewNotVisible(at row: Int) {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: newsSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
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
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
    
    var isShowingRetryAction: Bool {
        !feedImageRetryButton.isHidden
    }
    var isShowingImageLoadingIndicator: Bool {
        newsImageContainer.isShimmering
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var renderedImage: Data? {
        newsImageView.image?.pngData()
    }
}

private extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
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

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}
