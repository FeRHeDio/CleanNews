//
//  FeedCacheTestHelpers.swift
//  CleanNewsTests
//
//  Created by Fernando Putallaz on 19/11/2022.
//

import Foundation
import CleanNewsFramework

public func uniqueItem() -> NewsItem {
    NewsItem(id: UUID(), title: "some title", description: "some description", content: "some content")
}

public func uniqueItems() -> (models: [NewsItem], local: [LocalNewsItem]) {
    let models = [uniqueItem()]
    let local = models.map { LocalNewsItem(id: $0.id, title: $0.title, description: $0.description, content: $0.content) }
    
    return (models, local)
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
