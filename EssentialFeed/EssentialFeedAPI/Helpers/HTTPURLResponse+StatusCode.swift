//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 16/05/23.
//

import Foundation

extension HTTPURLResponse {
	private static var OK_200: Int { return 200 }
	
	var isOK: Bool {
		return statusCode == HTTPURLResponse.OK_200
	}
}
