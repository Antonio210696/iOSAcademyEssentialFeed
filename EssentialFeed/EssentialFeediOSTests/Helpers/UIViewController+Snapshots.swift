//
//  UIViewController+Snapshots.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Epifani on 22/06/23.
//

import UIKit

extension UIViewController {
	func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
		SnapshotWindow(configuration: configuration, root: self).snapshot()
	}
}

