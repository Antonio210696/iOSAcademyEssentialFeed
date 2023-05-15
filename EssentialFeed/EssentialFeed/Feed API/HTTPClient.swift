//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 09/04/23.
//

import Foundation

public protocol HTTPClientTask {
	func cancel()
}

public protocol HTTPClient {
	
	typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate thread, if needed.
	@discardableResult
	func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}

// end to end tests are a valid solution for testing multiple components
