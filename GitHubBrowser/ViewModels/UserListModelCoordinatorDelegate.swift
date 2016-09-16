//
//  UserListModelCoordinatorDelegate.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/15/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit

protocol UserListModelCoordinatorDelegate: class {
    
    // TODO: add model here to verify that call came from correct user model in coordinator
    func userListViewModelShouldNavigateToFollowers (ofUser userModel: GithubUserModel)
}
