//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 10/08/23.
//

import Foundation

public enum FeedEndpoint {
	case get(after: FeedImage? = nil)
	
	public func url(baseURL: URL) -> URL {
		switch self {
		case let .get(image):
			var components = URLComponents()
			components.scheme = baseURL.scheme
			components.host = baseURL.host
			components.path = baseURL.path + "/v1/feed"
			components.queryItems = [
				image.map { URLQueryItem(name: "after_id", value: $0.id.uuidString) },
				URLQueryItem(name: "limit", value: "10")
			].compactMap { $0 }
			
			return components.url!
		}
	}
}
