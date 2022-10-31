//
//  XCtestCase+MemoryLeakTracking.swift
//  CleanNewsTests
//
//  Created by Fernando Putallaz on 31/10/2022.
//

import XCTest

extension XCTestCase {
    func checkForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
