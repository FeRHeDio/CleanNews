//
//  NewsFeedImageViewModel.swift
//  CleanNewsiOS
//
//  Created by Fernando Putallaz on 20/03/2023.
//

struct NewsFeedImageViewModel<Image> {
    let title: String?
    let description: String?
    let image: Image?
    let content: String?
    let isLoading: Bool
    let shouldRetry: Bool
}
