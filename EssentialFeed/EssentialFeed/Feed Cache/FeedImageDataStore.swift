//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 17/05/23.
//

import Foundation

public protocol FeedImageDataStore {
	typealias Result = Swift.Result<Data?, Error>
	
	func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
