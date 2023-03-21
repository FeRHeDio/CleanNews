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
        let presentationAdapter = NewsFeedLoaderPresentationAdapter(newsLoader: newsFeedLoader)
        let refreshController = NewsRefreshController(delegate: presentationAdapter)
        let newsFeedViewController = NewsFeedViewController(refreshController: refreshController)
        presentationAdapter.presenter = NewsFeedPresenter(
            newsFeedView: NewsFeedViewAdapter(newsFeedViewController: newsFeedViewController, imageLoader: imageLoader),
            newsFeedLoadingView: WeakRefVirtualProxy(refreshController)
        )
        
        return newsFeedViewController
    }
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

private final class NewsFeedLoaderPresentationAdapter: NewsFeedRefreshViewControllerDelegate {
    let newsLoader: NewsLoader
    var presenter: NewsFeedPresenter?
    
    init(newsLoader: NewsLoader) {
        self.newsLoader = newsLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        newsLoader.load { [weak self] result in
            switch result {
            case let .success(newsFeed):
                self?.presenter?.didFinishLoadingFeed(with: newsFeed)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
