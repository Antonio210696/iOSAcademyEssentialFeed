//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 16/05/23.
//

import Foundation

public final class FeedImageDataMapper {
	public enum Error: Swift.Error {
		case invalidData
	}
	
	public static func map(_ data: Data, response: HTTPURLResponse) throws -> Data {
		guard response.isOK && !data.isEmpty else { throw Error.invalidData }
		
		return data
	}
}
