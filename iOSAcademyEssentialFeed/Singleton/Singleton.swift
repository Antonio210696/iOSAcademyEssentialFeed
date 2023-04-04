//
//  Singleton.swift
//  iOSAcademyEssentialFeed
//
//  Created by Antonio Epifani on 04/04/23.
//

import UIKit

struct LoggedInUser { }
struct FeedItem { }

// API Module
class ApiClient {
	static let shared = ApiClient()
	
	private init() {}
	
	func execute(_ : URLRequest, completion: (Data) -> Void) { }
}

extension ApiClient {
	func login(completion: (LoggedInUser) -> Void) { }
}

extension ApiClient {
	func loadFeed(completion: ([FeedItem]) -> Void) { }
}

class MockApiClient: ApiClient {
}

// Login module

class LoginViewController: UIViewController {
	var login: (((LoggedInUser) -> Void) -> Void)?
	
	func didTapLoginButton() {
		login? { user in
			// show next screen
		}
	}
}

// Feed Module

class FeedViewController: UIViewController {
	var loadFeed: ((([FeedItem]) -> Void) -> Void)?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		loadFeed? { loadedItems in
			
		}
	}
}
