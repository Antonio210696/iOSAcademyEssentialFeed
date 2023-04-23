//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 09/04/23.
//

import Foundation

public enum HTTPClientResult {
	case success(Data, HTTPURLResponse)
	case failure(Error)
}

public protocol HTTPClient {
	/// The completion handler can be invoked in any thread.
	/// Clients are responsible to dispatch to appropriate thread, if needed.
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

// end to end tests are a valid solution for testing multiple components
