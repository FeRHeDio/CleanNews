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
    public let content: String
    
    public init(id: UUID, title: String, description: String, content: String) {
        self.id = id
        self.title = title
        self.description = description
        self.content = content
    }
}
