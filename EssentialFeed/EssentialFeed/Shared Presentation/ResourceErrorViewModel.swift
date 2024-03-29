//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 12/05/23.
//

import Foundation

public struct ResourceErrorViewModel {
	public let message: String?
	
	public init(message: String?) {
		self.message = message
	}
	
	static var noError: ResourceErrorViewModel {
		return ResourceErrorViewModel(message: nil)
	}
	
	public static func error(message: String) -> ResourceErrorViewModel {
		return ResourceErrorViewModel(message: message)
	}
}
