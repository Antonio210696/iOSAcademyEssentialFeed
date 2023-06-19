//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 19/06/23.
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {
	
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "ImageComments"
		let presentationBundle = Bundle(for: ImageCommentsPresenter.self)
		
		assertLocalizedKeyAndValuesExist(in: presentationBundle, table)
	}
}
