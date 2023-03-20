//
//  NewsRefreshController.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 15/03/2023.
//

import UIKit

public final class NewsRefreshController: NSObject {
    private(set) lazy var view = binded(UIRefreshControl())
    
    private var viewModel: NewsFeedViewModel?
    
    init(viewModel: NewsFeedViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel?.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel?.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
