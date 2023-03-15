//
//  NewsRefreshController.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 15/03/2023.
//

import UIKit
import CleanNewsFramework

public final class NewsRefreshController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    var newsFeedLoader: NewsLoader?
    
    init(newsFeedLoader: NewsLoader) {
        self.newsFeedLoader = newsFeedLoader
    }
    
    var onRefresh: (([NewsItem]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        newsFeedLoader?.load { [weak self] result in
            if let newsFeed = try? result.get() {
                self?.onRefresh?(newsFeed)
            }
            self?.view.endRefreshing()
        }
    }
}
