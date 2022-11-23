//
//  NewsStoreSpecs.swift
//  CleanNews
//
//  Created by Fernando Putallaz on 23/11/2022.
//

import Foundation

public protocol NewsStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache()
    
    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPreviouslyInsertedCacheValues()
    
    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_hasNoSideEffectOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()
    
    func test_storeSideEffects_runSerially()
}

public  protocol FailableRetrieveNewsStoreSpecs: NewsStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectOnFailure()
}

public protocol FailableInsertNewsStoreSpecs: NewsStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

public protocol FailableDeleteNewsStoreSpecs: NewsStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}

public typealias FailableNewsStore = FailableRetrieveNewsStoreSpecs & FailableInsertNewsStoreSpecs & FailableDeleteNewsStoreSpecs
