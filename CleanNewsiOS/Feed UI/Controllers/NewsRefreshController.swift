//
//  NewsRefreshController.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 15/03/2023.
//

import UIKit

protocol NewsFeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class NewsRefreshController: NSObject, NewsFeedLoadingView {
    private(set) lazy var view = loadView()
    private var delegate: NewsFeedRefreshViewControllerDelegate?
    
    init(delegate: NewsFeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        delegate?.didRequestFeedRefresh()
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
