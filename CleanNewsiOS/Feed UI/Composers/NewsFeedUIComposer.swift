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
        let refreshController = NewsRefreshController(newsFeedLoader: newsFeedLoader)
        let newsFeedViewController = NewsFeedViewController(refreshController: refreshController)
        
        refreshController.onRefresh = { [weak newsFeedViewController] feed in
            newsFeedViewController?.tableModel = feed.map { model in
                NewsImageCellController(model: model, imageLoader: imageLoader)
            }
        }
        return newsFeedViewController
    }
}
