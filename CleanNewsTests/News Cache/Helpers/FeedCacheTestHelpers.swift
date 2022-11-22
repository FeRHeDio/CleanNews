//
//  FeedCacheTestHelpers.swift
//  CleanNewsTests
//
//  Created by Fernando Putallaz on 19/11/2022.
//

import Foundation
import CleanNews

public func uniqueItem() -> NewsItem {
    NewsItem(title: "some title", description: "some descri", content: "some content")
}

public func uniqueItems() -> (models: [NewsItem], local: [LocalNewsItem]) {
    let models = [uniqueItem(), uniqueItem()]
    let local = models.map { LocalNewsItem(title: $0.title, description: $0.description, content: $0.content) }
    
    return (models, local)
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
