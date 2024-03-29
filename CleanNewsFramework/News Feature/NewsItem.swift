//
//  NewsItem.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 27/10/2022.
//

import Foundation

public struct NewsItem: Equatable, Decodable {
    public let id: UUID
    public let title: String
    public let description: String
    public let imageURL: URL
    public let content: String
    
    public init(id: UUID, title: String, description: String, imageURL: URL, content: String) {
        self.id = id
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.content = content
    }
}
