//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Epifani on 04/05/23.
//

import XCTest
import EssentialFeed

extension FeedUIIntegrationTests {
	private class DummyView: ResourceView {
		func display(_ viewModel: Any) { }
	}
	
	var loadError: String {
		LoadResourcePresenter<Any, DummyView>.loadError
	}
	
	var feedTitle: String {
		FeedPresenter.title
	}
}
