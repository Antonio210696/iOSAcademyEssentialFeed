//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Antonio Epifani on 26/05/23.
//

import XCTest
@testable import EssentialApp
import EssentialFeediOS

class SceneDelegateTests: XCTestCase {
	func test_sceneWillConnectTOSession_configuresRootViewCOntroller() {
		let sut = SceneDelegate()
		sut.window = UIWindow()
		
		sut.configureWindow()
		
		let root = sut.window?.rootViewController
		let rootNavigation = root as? UINavigationController
		let topController = rootNavigation?.topViewController
		
		XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
		XCTAssertTrue(topController is FeedViewController, "Expected a feed controller as top view controoler, got \(String(describing: topController)) instead")
	}
}
