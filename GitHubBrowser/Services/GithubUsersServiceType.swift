//
//  GithubUserServiceType.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/14/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit


protocol GithubUsersServiceType {
    
    func retrieveUserList (pagingMarker: GithubUsersPagingMarkerType?,
                           completionHandler: ([GithubUserModel]?, GithubUsersPagingMarkerType?, NSError?) -> Void)
}

/// Server as an identifier of retrieved batch, is mainly used to work with paging when retrieving data
protocol GithubUsersPagingMarkerType {
}