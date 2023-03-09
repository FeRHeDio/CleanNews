//
//  LocalNewsItem.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 08/11/2022.
//

import Foundation

public struct LocalNewsItem: Equatable {
    public let id: UUID
    public let title: String
    public let description: String
    public let imageURL: String
    public let content: String
    
    public init(id: UUID, title: String, description: String, imageURL: String, content: String) {
        self.id = id
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.content = content
    }
}
