//
//  LocalNewsItem.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 08/11/2022.
//

import Foundation

public struct LocalNewsItem: Equatable {
    public let title: String
    public let description: String
    public let content: String
    
    public init(title: String, description: String, content: String) {
        self.title = title
        self.description = description
        self.content = content
    }
}
