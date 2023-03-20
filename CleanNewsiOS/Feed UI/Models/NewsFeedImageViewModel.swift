//
//  NewsFeedImageViewModel.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 20/03/2023.
//

import Foundation
import UIKit
import CleanNewsFramework

final class NewsFeedImageViewModel {
    typealias Observer<T> = (T) -> Void
    
    private var task: FeedImageDataLoaderTask?
    private let model: NewsItem
    private let newsImageLoader: FeedImageDataLoader
    
    init(model: NewsItem, newsImageLoader: FeedImageDataLoader) {
        self.model = model
        self.newsImageLoader = newsImageLoader
    }
    
    var description: String? {
        model.description
    }
    
    var title: String? {
        model.title
    }
    
    var content: String? {
        model.content
    }
    
    var onImageLoad: Observer<UIImage>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = newsImageLoader.loadImageData(from: model.imageURL) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(UIImage.init) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
