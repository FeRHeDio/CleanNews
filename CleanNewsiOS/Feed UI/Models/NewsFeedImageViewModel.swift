//
//  NewsFeedImageViewModel.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 20/03/2023.
//

import Foundation
import CleanNewsFramework

final class NewsFeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    private var task: FeedImageDataLoaderTask?
    private let model: NewsItem
    private let newsImageLoader: FeedImageDataLoader
    private let imageTransfer: (Data) -> Image?
    
    init(model: NewsItem, newsImageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.newsImageLoader = newsImageLoader
        self.imageTransfer = imageTransformer
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
    
    var onImageLoad: Observer<Image>?
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
        if let image = (try? result.get()).flatMap(imageTransfer) {
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
