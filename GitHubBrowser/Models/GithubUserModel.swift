//
//  GithubUserModel.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/14/16.
//  Copyright © 2016 None. All rights reserved.
//

import Foundation

struct GithubUserModel {
    let id: Int
    let username: String
    let avatarUrl: NSURL?
    let githubLink: NSURL
    let followersLink: NSURL
    
    init (id: Int, username: String, avatarUrl: NSURL?, githubLink: NSURL, followersLink: NSURL) {
        self.id = id
        self.username = username
        self.avatarUrl = avatarUrl
        self.githubLink = githubLink
        self.followersLink = followersLink
    }
    
    static func userModelsFromRawJSONData (rawUsers: Array<Dictionary<String, AnyObject>>) -> [GithubUserModel] {
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
