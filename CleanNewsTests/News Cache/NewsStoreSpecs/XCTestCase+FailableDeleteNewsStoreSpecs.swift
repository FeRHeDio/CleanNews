//
//  FailableDeleteNewsStoreSpecs.swift
//  CleanNewsTests
//
//  Created by Fernando Putallaz on 23/11/2022.
//

import XCTest
import CleanNews

extension FailableDeleteNewsStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: NewsStore, file: StaticString = #filePath, line: UInt = #line) {
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    
    func assertThatDeleteHsNoSideEffectsOnDeletionError(on sut: NewsStore, file: StaticString = #filePath, line: UInt = #line) {

        deleteCache(from: sut)
        expect(sut, toRetrieve: .success(.none))
    }
}

