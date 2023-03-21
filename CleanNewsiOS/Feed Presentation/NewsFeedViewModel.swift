//
//  NewsFeedViewModel.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 20/03/2023.
//

import Foundation
import CleanNewsFramework

final class NewsFeedViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let newsFeedLoader: NewsLoader?
    
    init(newsFeedLoader: NewsLoader) {
        self.newsFeedLoader = newsFeedLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[NewsItem]>?
    
    func loadFeed() {
        onLoadingStateChange?(true)
        newsFeedLoader?.load { [weak self] result in
            if let newsFeed = try? result.get() {
                self?.onFeedLoad?(newsFeed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
