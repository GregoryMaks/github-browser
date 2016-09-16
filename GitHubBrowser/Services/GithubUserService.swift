//
//  GithubUserService.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/14/16.
//  Copyright © 2016 None. All rights reserved.
//

import Foundation
import Alamofire


class GithubUserService: GithubUserServiceType {
    
    func retrieveGlobalUserList (sinceId: Int?,
                                 itemsPerPage: GithubUserServiceBatchSize,
                                 completionHandler: ([GithubUserModel]?, NSError?) -> Void) {

        retrieveUsers(atURL: NSURL(string: "https://api.github.com/users")!,
                      sinceId: sinceId,
                      itemsPerPage: itemsPerPage,
                      completionHandler: completionHandler)
    }
    
    func retrieveFollowersList (followersUrl: NSURL,
                                sinceId: Int?,
                                itemsPerPage: GithubUserServiceBatchSize,
                                completionHandler: ([GithubUserModel]?, NSError?) -> Void) {
        
        retrieveUsers(atURL: followersUrl,
                      sinceId: sinceId,
                      itemsPerPage: itemsPerPage,
                      completionHandler: completionHandler)
    }
    
    func retreiveUserData (username: String,
                           completionHandler: (GithubUserModel?, NSError?) -> Void) {
        
        Alamofire.request(.GET, "https://api.github.com/users/\(username)")
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: dispatch_get_main_queue(),
                          options: NSJSONReadingOptions()) { (response: Response<AnyObject, NSError>) in
                            guard (response.result.isSuccess) else {
                                print(response.result.error)
                                completionHandler(nil, response.result.error)
                                return
                            }
                            
                            let rawData = response.result.value as? Dictionary<String, AnyObject>
                            guard (rawData != nil) else {
                                completionHandler(nil, nil)
                                return
                            }
                            
                            print("Received result \(rawData)")
                            let users: Array<Dictionary<String, AnyObject>> = [rawData!]
                            let models = self.parseRawUsers(users)
                            completionHandler(models.count > 0 ? models[0] : nil, nil)
        }
    }
}

private extension GithubUserService {
    
    func retrieveUsers (atURL url: NSURL,
                        sinceId: Int?,
                        itemsPerPage: GithubUserServiceBatchSize,
                        completionHandler: ([GithubUserModel]?, NSError?) -> Void) {
        
        var parameters = [String: AnyObject]()
        if (sinceId != nil) {
            parameters["since"] = sinceId!
        }
        
        switch itemsPerPage {
        case .Custom(let value):
            parameters["per_page"] = value
        default:
            break;
        }
        
        Alamofire.request(.GET, url, parameters: parameters)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: dispatch_get_main_queue(),
                          options: NSJSONReadingOptions()) { (response: Response<AnyObject, NSError>) in
                            guard (response.result.isSuccess) else {
                                print(response.result.error)
                                completionHandler(nil, response.result.error)
                                return
                            }
                            
                            let rawData = response.result.value as? Array<Dictionary<String, AnyObject>>
                            guard (rawData != nil) else {
                                completionHandler(nil, nil)
                                return
                            }
                            
                            print("Received result \(rawData)")
                            let models = self.parseRawUsers(rawData!)
                            completionHandler(models, nil)
        }
    }
    
    func parseRawUsers (rawUsers: Array<Dictionary<String, AnyObject>>) -> [GithubUserModel] {
        
        var models = [GithubUserModel]()
        for rawUser in rawUsers {
            if  let username = rawUser["login"] as? String,
                let id = rawUser["id"] as? Int,
                let githubLinkString = rawUser["html_url"] as? String,
                let followersLinkString = rawUser["followers_url"] as? String {
                
                let avatarUrl = rawUser["avatar_url"] as? String
                
                if  let githubLink = NSURL(string: githubLinkString),
                    let followersLink = NSURL(string: followersLinkString) {
                    
                    let model = GithubUserModel(id: id,
                                                username: username,
                                                avatarUrl: avatarUrl != nil ? NSURL(string: avatarUrl!) : nil,
                                                githubLink: githubLink,
                                                followersLink: followersLink)
                    
                    models.append(model)
                }
            }
        }
        
        return models
    }
}
