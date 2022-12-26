//
//  NewsCachePolicy.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 21/11/2022.
//

import Foundation

internal final class NewsCachePolicy {
    private init() {}
    
    private static let calendar = Calendar(identifier: .gregorian)
    private static var maxCacheDateInDays: Int {
        return 7
    }
    
    internal static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheDateInDays, to: timestamp) else {
            return false
        }
        
        return date < maxCacheAge
    }
}
