//
//  GithubUserService.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/14/16.
//  Copyright © 2016 None. All rights reserved.
//

import Foundation
import Alamofire


class GithubAllUsersService: GithubUsersServiceType {
    
    func retrieveUserList (pagingMarker: GithubUsersPagingMarkerType?,
                           completionHandler: ([GithubUserModel]?, GithubUsersPagingMarkerType?, NSError?) -> Void) {
        
        let marker = pagingMarker as? GithubAllUsersPagingMarker
        
        var parameters = [String: AnyObject]()
        if let sinceId = marker?.lastUserId {
            parameters["since"] = NSNumber(longLong: sinceId)
        }

//        switch itemsPerPage {
//        case .Custom(let value):
//            parameters["per_page"] = value
//        default:
//            break;
//        }

        Alamofire.request(.GET, NSURL(string: "https://api.github.com/users")!, parameters: parameters)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: dispatch_get_main_queue(),
                          options: NSJSONReadingOptions()) { (response: Response<AnyObject, NSError>) in
                            guard (response.result.isSuccess) else {
                                print(response.result.error)
                                completionHandler(nil, nil, response.result.error)
                                return
                            }
                            
                            let rawData = response.result.value as? Array<Dictionary<String, AnyObject>>
                            guard (rawData != nil) else {
                                completionHandler(nil, nil, nil)
                                return
                            }
                            print("Received result \(rawData)")
                            
                            let models = GithubUserModel.userModelsFromRawJSONData(rawData!)
                            
                            let lastUser = models.last
                            let pagingMarker = GithubAllUsersPagingMarker(lastUserId: Int64(lastUser?.id ?? 0))
                            
                            completionHandler(models, pagingMarker, nil)
        }
    }
}

class GithubAllUsersPagingMarker: GithubUsersPagingMarkerType {
    
    let lastUserId: Int64
    
    init (lastUserId: Int64 = 0) {
        self.lastUserId = lastUserId
    }
}