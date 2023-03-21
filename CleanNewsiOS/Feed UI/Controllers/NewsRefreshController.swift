//
//  NewsRefreshController.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 15/03/2023.
//

import UIKit

public final class NewsRefreshController: NSObject, NewsFeedLoadingView {
    private(set) lazy var view = loadView()
    private var loadFeed: () -> Void?
    
    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
    }
    
    @objc func refresh() {
        loadFeed()
    }
    
    func display(_ viewModel: NewsFeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
