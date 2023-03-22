//
//  NewsImageCellController.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 16/03/2023.
//

import UIKit
import CleanNewsFramework

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class NewsImageCellController: NewsFeedImageView {
    private let delegate: FeedImageCellControllerDelegate
    private lazy var cell = NewsItemCell()
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view() -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelImageRequest()
    }
    
    func display(_ viewModel: NewsFeedImageViewModel<UIImage>) {
        cell.titleLabel.text = viewModel.title
        cell.descriptionLabel.text = viewModel.description
        cell.newsImageView.image = viewModel.image
        cell.contentLabel.text = viewModel.content
        cell.newsImageContainer.isShimmering = viewModel.isLoading
        cell.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell.onRetry = delegate.didRequestImage
    }
}
