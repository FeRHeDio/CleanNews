//
//  NewsFeedPresenter.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 21/03/2023.
//

import CleanNewsFramework

protocol NewsFeedLoadingView: AnyObject {
    func display(isLoading: Bool)
}

protocol NewsFeedView {
    func display(newsFeed: [NewsItem])
}

final class NewsFeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    private let newsFeedLoader: NewsLoader?
    
    init(newsFeedLoader: NewsLoader) {
        self.newsFeedLoader = newsFeedLoader
    }
    
    var newsFeedView: NewsFeedView?
    weak var newsFeedLoadingView: NewsFeedLoadingView?
    
    func loadFeed() {
        newsFeedLoadingView?.display(isLoading: true)
        newsFeedLoader?.load { [weak self] result in
            if let newsFeed = try? result.get() {
                self?.newsFeedView?.display(newsFeed: newsFeed)
            }
            self?.newsFeedLoadingView?.display(isLoading: false)
        }
    }
}
