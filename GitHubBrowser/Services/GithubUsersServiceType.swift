//
//  GithubUserServiceType.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/14/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit


//enum GithubUsersServiceBatchSize {
//    case Default
//    case Custom(Int)
//}

//protocol GithubUserServiceType {
//    
//    func retrieveGlobalUserList (sinceId: Int?,
//                                 itemsPerPage: GithubUserServiceBatchSize,
//                                 completionHandler: ([GithubUserModel]?, NSError?) -> Void)
//    
//    func retrieveFollowersList (followersUrl: NSURL,
//                                sinceId: Int?,
//                                itemsPerPage: GithubUserServiceBatchSize,
//                                completionHandler: ([GithubUserModel]?, NSError?) -> Void)
//    
//    func retreiveUserData (username: String,
//                           completionHandler: (GithubUserModel?, NSError?) -> Void)
//}

protocol GithubUsersServiceType {
    
    func retrieveUserList (pagingMarker: GithubUsersPagingMarkerType?,
                           completionHandler: ([GithubUserModel]?, GithubUsersPagingMarkerType?, NSError?) -> Void)
}

/// Server as an identifier of retrieved batch, is mainly used to work with paging when retrieving data
protocol GithubUsersPagingMarkerType {
}