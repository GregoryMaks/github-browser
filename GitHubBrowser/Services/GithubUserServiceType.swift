//
//  GithubUserServiceType.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/14/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit


enum GithubUserServiceBatchSize {
    case Default
    case Custom(Int)
}


protocol GithubUserServiceType {
    
    func retrieveGlobalUserList (sinceId: Int?,
                                 itemsPerPage: GithubUserServiceBatchSize,
                                 completionHandler: ([GithubUserModel]?, NSError?) -> Void)
    
    func retrieveFollowersList (followersUrl: NSURL,
                                sinceId: Int?,
                                itemsPerPage: GithubUserServiceBatchSize,
                                completionHandler: ([GithubUserModel]?, NSError?) -> Void)
    
    func retreiveUserData (username: String,
                           completionHandler: (GithubUserModel?, NSError?) -> Void)
}
