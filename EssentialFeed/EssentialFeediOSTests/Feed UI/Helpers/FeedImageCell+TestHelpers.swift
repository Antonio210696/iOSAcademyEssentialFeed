//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Epifani on 11/05/23.
//

import UIKit
import EssentialFeediOS

extension FeedImageCell {
	var isShowingRetryAction: Bool {
		return !feedImageRetryButton.isHidden
	}
	var isShowingLocation: Bool {
		return !locationContainer.isHidden
	}
	
	var isShowingImageLoadingIndicator: Bool {
		return feedImageContainer.isShimmering
	}
	
	func simulateRetryAction() {
		feedImageRetryButton.simulateTap()
	}
	
	var locationText: String? {
		return locationLabel.text
	}
	
	var descriptionText: String? {
		return descriptionLabel.text
	}
	
	var renderedImage: Data? {
		return feedImageView.image?.pngData()
	}
}
