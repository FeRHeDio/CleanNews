//
//  NewsImageCellController.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 16/03/2023.
//

import UIKit
import CleanNewsFramework

public final class NewsImageCellController {
    private let viewModel: NewsFeedImageViewModel
    
    init(viewModel: NewsFeedImageViewModel) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = binded(NewsItemCell())
        viewModel.loadImageData()
        
        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
    
    private func binded(_ cell: NewsItemCell) -> NewsItemCell {
        cell.titleLabel.text = viewModel.title
        cell.descriptionLabel.text = viewModel.description
        cell.contentLabel.text = viewModel.content
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.newsImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.newsImageContainer.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }
        
        return cell
    }
}
