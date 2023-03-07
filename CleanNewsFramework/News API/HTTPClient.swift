//
//  HTTPClient.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 26/10/2022.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
        /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads if needed.
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
