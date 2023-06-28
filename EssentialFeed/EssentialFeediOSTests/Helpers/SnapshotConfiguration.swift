//
//  SnapshotConfiguration.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Epifani on 22/06/23.
//

import UIKit

struct SnapshotConfiguration {
	let size: CGSize
	let safeAreaInserts: UIEdgeInsets
	let layoutMargins: UIEdgeInsets
	let traitCollection: UITraitCollection
	
	static func iPhone13(style: UIUserInterfaceStyle) -> SnapshotConfiguration {
		return SnapshotConfiguration(
			size: CGSize(width: 390, height: 844),
			safeAreaInserts: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
			layoutMargins: UIEdgeInsets(top: 47, left: 16, bottom: 34, right: 16),
			traitCollection: UITraitCollection(traitsFrom: [
				.init(forceTouchCapability: .available),
				.init(layoutDirection: .leftToRight),
				.init(preferredContentSizeCategory: .medium),
				.init(userInterfaceIdiom: .phone),
				.init(horizontalSizeClass: .compact),
				.init(verticalSizeClass: .regular),
				.init(displayScale: 2),
				.init(displayGamut: .P3),
				.init(userInterfaceStyle: style)
			])
		)
	}
}