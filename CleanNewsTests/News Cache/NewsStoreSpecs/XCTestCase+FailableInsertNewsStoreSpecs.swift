//
//  XCTestCase+FailableInsertNewsStoreSpecs.swift
//  CleanNewsTests
//
//  Created by Fernando Putallaz on 23/11/2022.
//

import XCTest
import CleanNews

extension FailableInsertNewsStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: NewsStore, file: StaticString = #filePath, line: UInt = #line) {
        
        let news = uniqueItems().local
        let timestamp = Date()
        
        let insertionError = insert((news, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: NewsStore, file: StaticString = #filePath, line: UInt = #line) {
        
        let news = uniqueItems().local
        let timestamp = Date()
        
        insert((news, timestamp), to: sut)
        
        expect (sut, toRetrieve: .success(.empty), file: file, line: line)
    }
}

