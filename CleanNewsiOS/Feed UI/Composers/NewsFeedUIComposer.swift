//
//  NewsFeedUIComposer.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 17/03/2023.
//

import UIKit
import CleanNewsFramework

public final class NewsFeedUIComposer {
    private init() {}
    
    public static func newsFeedComposedWith(newsFeedLoader: NewsLoader, imageLoader: FeedImageDataLoader) -> NewsFeedViewController {
        let presenter = NewsFeedPresenter(newsFeedLoader: newsFeedLoader)
        let refreshController = NewsRefreshController(presenter: presenter)
        let newsFeedViewController = NewsFeedViewController(refreshController: refreshController)
        presenter.newsFeedLoadingView = WeakRefVirtualProxy(refreshController)
        presenter.newsFeedView = NewsFeedViewAdapter(newsFeedViewController: newsFeedViewController, imageLoader: imageLoader)
        
        return newsFeedViewController
    }
    
//    private static func adaptFeedToCellControllers(forwardingTo controller: NewsFeedViewController, loader: FeedImageDataLoader) -> ([NewsItem]) -> Void {
//        return { [weak controller] feed in
//            controller?.tableModel = feed.map { model in
//                NewsImageCellController(viewModel: NewsFeedImageViewModel(model: model, newsImageLoader: loader, imageTransformer: UIImage.init))
//            }
//        }
//    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: NewsFeedLoadingView where T: NewsFeedLoadingView {
    func display(_ viewModel: NewsFeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class NewsFeedViewAdapter: NewsFeedView {
    private weak var newsFeedViewController: NewsFeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(newsFeedViewController: NewsFeedViewController, imageLoader: FeedImageDataLoader) {
        self.newsFeedViewController = newsFeedViewController
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: NewsFeedViewModel) {
        newsFeedViewController?.tableModel = viewModel.newsFeed.map { model in
            NewsImageCellController(viewModel: NewsFeedImageViewModel(model: model, newsImageLoader: imageLoader, imageTransformer: UIImage.init))
        }
    }
}
