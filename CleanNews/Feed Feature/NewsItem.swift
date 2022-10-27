//
//  NewsItem.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 27/10/2022.
//

import Foundation

public struct NewsItem: Equatable, Decodable {
    public let title: String
    public let description: String
    public let content: String
    
    public init(title: String, description: String, content: String) {
        self.title = title
        self.description = description
        self.content = content
    }
}
