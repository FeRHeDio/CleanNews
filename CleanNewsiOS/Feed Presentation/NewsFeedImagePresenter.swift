//
//  NewsFeedImagePresenter.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 21/03/2023.
//

import Foundation
import CleanNewsFramework

protocol NewsFeedImageView {
    associatedtype Image
    
    func display(_ model: NewsFeedImageViewModel<Image>)
}

final class NewsFeedImagePresenter<View: NewsFeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    internal init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: NewsItem) {
        view.display(
            NewsFeedImageViewModel(
                title: model.title,
                description: model.description,
                image: nil,
                content: model.content,
                isLoading: true,
                shouldRetry: false
            )
        )
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: NewsItem) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(
            NewsFeedImageViewModel(
                title: model.title,
                description: model.description,
                image: image,
                content: model.content,
                isLoading: false,
                shouldRetry: false
            )
        )
    }
    
    func didFinishLoadingImageData(with error: Error, for model: NewsItem) {
        view.display(
            NewsFeedImageViewModel(
                title: model.title,
                description: model.description,
                image: nil,
                content: model.content,
                isLoading: false,
                shouldRetry: true
            )
        )
    }
}
