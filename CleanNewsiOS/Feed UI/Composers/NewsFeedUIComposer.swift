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
        let newsFeedViewModel = NewsFeedViewModel(newsFeedLoader: newsFeedLoader)
        let refreshController = NewsRefreshController(viewModel: newsFeedViewModel)
        let newsFeedViewController = NewsFeedViewController(refreshController: refreshController)
        
        newsFeedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: newsFeedViewController, loader: imageLoader)
        return newsFeedViewController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: NewsFeedViewController, loader: FeedImageDataLoader) -> ([NewsItem]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                NewsImageCellController(model: model, imageLoader: loader)
            }
        }
    }
}
