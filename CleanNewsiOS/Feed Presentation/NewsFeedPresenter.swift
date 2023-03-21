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
    var newsFeedView: NewsFeedView?
    var newsFeedLoadingView: NewsFeedLoadingView?
    
    func didStartLoadingFeed() {
        newsFeedLoadingView?.display(NewsFeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with newsFeed: [NewsItem]) {
        newsFeedView?.display(NewsFeedViewModel(newsFeed: newsFeed))
        newsFeedLoadingView?.display(NewsFeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        newsFeedLoadingView?.display(NewsFeedLoadingViewModel(isLoading: false))
    }
}
