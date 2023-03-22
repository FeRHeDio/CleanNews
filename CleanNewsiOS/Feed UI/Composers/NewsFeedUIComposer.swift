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

extension WeakRefVirtualProxy: NewsFeedImageView where T: NewsFeedImageView, T.Image == UIImage {
    func display(_ model: NewsFeedImageViewModel<UIImage>) {
        object?.display(model)
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
            let adapter = NewsFeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<NewsImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = NewsImageCellController(delegate: adapter)
            
            adapter.presenter = NewsFeedImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)
            
            return view
        }
    }
}

final class NewsFeedImageDataLoaderPresentationAdapter<View: NewsFeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: NewsItem
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    var presenter: NewsFeedImagePresenter<View, Image>?
    
    init(model: NewsItem, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        
        task = imageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
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
