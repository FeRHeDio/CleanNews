//
//  NewsImageCellController.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 16/03/2023.
//

import UIKit
import CleanNewsFramework

public final class NewsImageCellController {
    private var task: FeedImageDataLoaderTask?
    private var model: NewsItem
    private var imageLoader: FeedImageDataLoader
    
    init(model: NewsItem, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = NewsItemCell()
        cell.titleLabel.text = self.model.title
        cell.descriptionLabel.text = self.model.description
        cell.newsImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.newsImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self else { return }
         
            self.task = self.imageLoader.loadImageData(from: self.model.imageURL) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.newsImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.newsImageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    func preload() {
        task = imageLoader.loadImageData(from: model.imageURL) { _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
