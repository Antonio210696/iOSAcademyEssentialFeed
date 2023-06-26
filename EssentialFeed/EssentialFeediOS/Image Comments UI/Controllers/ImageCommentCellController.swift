//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Antonio Epifani on 22/06/23.
//

import UIKit
import EssentialFeed

public class ImageCommentCellController: NSObject, UITableViewDataSource {
	
	private let model: ImageCommentViewModel
	
	public init(model: ImageCommentViewModel) {
		self.model = model
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: ImageCommentCell = tableView.dequeuReusableCell()
		cell.messageLabel.text = model.message
		cell.usernameLabel.text = model.username
		cell.dateLabel.text = model.date
		
		return cell
	}
}
