//
//  EssentialAppUITestsLaunchTests.swift
//  EssentialAppUITests
//
//  Created by Antonio Epifani on 14/05/23.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
		let app = XCUIApplication()
		
		app.launch()
		
		XCTAssertEqual(app.cells.count, 22)
//		XCTAssertEqual(app.cells.firstMatch.images, 1)
    }
}
