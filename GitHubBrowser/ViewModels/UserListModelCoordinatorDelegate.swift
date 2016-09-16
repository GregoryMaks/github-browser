//
//  UserListModelCoordinatorDelegate.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/15/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit

protocol UserListModelCoordinatorDelegate: class {
    
    func userListViewModelShouldNavigateToFollowers (ofUser userModel: GithubUserModel)
}
