//
//  GithubFollowersService.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/19/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit
import Alamofire


class GithubFollowersUsersService: GithubUsersServiceType {

    private let user: GithubUserModel
    
    init (user: GithubUserModel) {
        self.user = user
    }
    
    func retrieveUserList (pagingMarker: GithubUsersPagingMarkerType?,
                           completionHandler: ([GithubUserModel]?, GithubUsersPagingMarkerType?, NSError?) -> Void) {
        
        let marker = pagingMarker as? GithubFollowersUsersPagingMarker
        let followersURL = marker?.nextPageURL ?? self.user.followersLink
        
        Alamofire.request(.GET, followersURL)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: dispatch_get_main_queue(),
                          options: NSJSONReadingOptions()) { (response: Response<AnyObject, NSError>) in
                            guard (response.result.isSuccess) else {
                                print(response.result.error)
                                completionHandler(nil, nil, response.result.error)
                                return
                            }
                            
                            // TODO: RETRIEVE PAGING MARKER HERE
                            var pagingMarker: GithubFollowersUsersPagingMarker? = nil
                            
                            let rawData = response.result.value as? Array<Dictionary<String, AnyObject>>
                            guard (rawData != nil) else {
                                completionHandler(nil, pagingMarker, nil)
                                return
                            }
                            
                            print("Received result \(rawData)")
                            let models = GithubUserModel.userModelsFromRawJSONData(rawData!)
                            completionHandler(models, pagingMarker, nil)
        }
    }
    
}

class GithubFollowersUsersPagingMarker: GithubUsersPagingMarkerType {
    
    let nextPageURL: NSURL?
    
    init (nextPageURL: NSURL?) {
        self.nextPageURL = nextPageURL
    }
}
