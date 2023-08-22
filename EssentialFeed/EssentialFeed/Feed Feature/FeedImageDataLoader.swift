//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Antonio Epifani on 01/05/23.
//

import Foundation

public protocol FeedImageDataLoader {
	func loadImageData(from url: URL) throws -> Data
}
