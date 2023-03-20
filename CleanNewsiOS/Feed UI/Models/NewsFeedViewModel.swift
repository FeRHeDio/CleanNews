//
//  NewsFeedViewModel.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 20/03/2023.
//

import Foundation
import CleanNewsFramework

final class NewsFeedViewModel {
    private let newsFeedLoader: NewsLoader?
    
    init(newsFeedLoader: NewsLoader) {
        self.newsFeedLoader = newsFeedLoader
    }
    
    var onChange: ((NewsFeedViewModel) -> Void)?
    var onFeedLoad: (([NewsItem]) -> Void)?
    
    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }
    
    func loadFeed() {
        isLoading = true
        newsFeedLoader?.load { [weak self] result in
            if let newsFeed = try? result.get() {
                self?.onFeedLoad?(newsFeed)
            }
            self?.isLoading = false
        }
    }
}
