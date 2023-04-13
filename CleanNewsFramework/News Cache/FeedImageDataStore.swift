//
//  FeedImageDataStore.swift
//  CleanNewsFramework
//
//  Created by Fernando Putallaz on 13/04/2023.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
