//
//  SharedTestHelpers.swift
//  CleanNewsTests
//
//  Created by Fernando Putallaz on 19/11/2022.
//

import Foundation
import CleanNewsFramework

func anyNSError() -> NSError {
    NSError(domain: "any", code: 0)
}

func anyURL() -> URL {
    URL(string: "http://a-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}

func nonHTTPURLResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}
