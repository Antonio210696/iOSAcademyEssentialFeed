//
//  FeedImageDataCache.swift
//  EssentialApp
//
//  Created by Antonio Epifani on 25/05/23.
//

import Foundation

public protocol FeedImageDataCache {
	typealias Result = Swift.Result<Void, Swift.Error>
	
	func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
