//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 19/06/23.
//

import Foundation

public final class ImageCommentsPresenter	{
	public static var title: String {
		return NSLocalizedString(
			"IMAGE_COMMENTS_VIEW_TITLE",
			tableName: "ImageComments",
			bundle: Bundle(for: Self.self),
			comment: "Title for the comments view")
	}
}
