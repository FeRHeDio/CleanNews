//
//  NewsFeedPresenter.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 21/03/2023.
//

import CleanNewsFramework

struct NewsFeedLoadingViewModel {
    let isLoading: Bool
}

protocol NewsFeedLoadingView {
    func display(_ viewModel: NewsFeedLoadingViewModel)
}

struct NewsFeedViewModel {
    let newsFeed: [NewsItem]
}

protocol NewsFeedView {
    func display(_ viewModel: NewsFeedViewModel)
}

final class NewsFeedPresenter {
    private let newsFeedLoader: NewsLoader?
    
    init(newsFeedLoader: NewsLoader) {
        self.newsFeedLoader = newsFeedLoader
    }
    
    var newsFeedView: NewsFeedView?
    var newsFeedLoadingView: NewsFeedLoadingView?
    
    func loadFeed() {
        newsFeedLoadingView?.display(NewsFeedLoadingViewModel(isLoading: true))
        newsFeedLoader?.load { [weak self] result in
            if let newsFeed = try? result.get() {
                self?.newsFeedView?.display(NewsFeedViewModel(newsFeed: newsFeed))
            }
            self?.newsFeedLoadingView?.display(NewsFeedLoadingViewModel(isLoading: false))
        }
    }
}
