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
    let githubLink: NSURL?
    let followersLink: NSURL?
    
    init (id: Int, username: String, avatarUrl: NSURL?, githubLink: NSURL?, followersLink: NSURL?) {
        self.id = id
        self.username = username
        self.avatarUrl = avatarUrl
        self.githubLink = githubLink
        self.followersLink = followersLink
    }
}
