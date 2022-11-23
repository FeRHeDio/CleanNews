//
//  XCTestCase+FailableRetrieveNewsStoreSpecs.swift
//  CleanNewsTests
//
//  Created by Fernando Putallaz on 23/11/2022.
//

import XCTest
import CleanNews

extension FailableRetrieveNewsStoreSpecs where Self: XCTestCase {
 
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: NewsStore, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectOnFailure(on sut: NewsStore, file: StaticString = #filePath, line: UInt = #line) {
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
    }
}

extension FailableDeleteNewsStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: NewsStore, file: StaticString = #filePath, line: UInt = #line) {
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    
    func assertThatDeleteHsNoSideEffectsOnDeletionError(on sut: NewsStore, file: StaticString = #filePath, line: UInt = #line) {

        deleteCache(from: sut)
        expect(sut, toRetrieve: .empty)
    }
}
