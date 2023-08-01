//
//  ImageCommentsEndpoint.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 05/07/23.
//

import Foundation

public enum ImageCommentsEndpoint {
	case get(FeedImage)
	
	public func url(baseURL: URL) -> URL {
		switch self {
		case let .get(image):
			return baseURL.appending(path: "/v1/image/\(image.id)/comments")
		}
	}
}
