//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Epifani on 11/05/23.
//

import UIKit

extension UIButton {
	func simulateTap() {
		allTargets.forEach({ target in
			actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
				(target as NSObject).perform(Selector($0))
			}
		})
	}
}
