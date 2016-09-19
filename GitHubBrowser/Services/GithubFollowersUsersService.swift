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
                            
                            var pagingMarker: GithubFollowersUsersPagingMarker? = nil
                            if let link = response.response?.headerLinks()["next"] {
                                pagingMarker = GithubFollowersUsersPagingMarker(nextPageURL: link)
                            }
                            
                            let rawData = response.result.value as? Array<Dictionary<String, AnyObject>>
                            guard (rawData != nil) else {
                                completionHandler(nil, pagingMarker, nil)
                                return
                            }
                            
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

extension NSHTTPURLResponse {
    
    func headerLinks () -> [String : NSURL?] {
        var result = [String : NSURL?]()
        
        // Here we are parsing links
        // Example:
        // <https://api.github.com/user/1/followers?page=2>; rel="next", <https://api.github.com/user/1/followers?page=656>; rel="last"
        
        if let rawLinksString: String = self.allHeaderFields[NSString(string: "Link") as NSObject] as? String {
            
            let pairs: [String] = rawLinksString.componentsSeparatedByString(",")
            for pair in pairs {
                
                let valueKey: [String] = pair.componentsSeparatedByString(";")
                guard valueKey.count == 2 else {
                    continue
                }
                
                let value = valueKey[0]
                    .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    .stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
                
                var key = valueKey[1]
                    .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                if (key.characters.startsWith("rel=".characters)) {
                    key.removeRange(key.rangeOfString("rel=")!)
                    key = key
                        .stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
                    
                    key = key.stringByRemovingPercentEncoding ?? ""
                }
                
                result[key] = NSURL(string: value)
            }
        }
        
        return result
    }
}
