//
//  GithubUserModel.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/14/16.
//  Copyright © 2016 None. All rights reserved.
//

import Foundation

struct GithubUserModel {
    let username: String
    let avatarUrl: NSURL?
    let githubLink: NSURL
    
    init (username: String, avatarUrl: NSURL?, githubLink: NSURL) {
        self.username = username
        self.avatarUrl = avatarUrl
        self.githubLink = githubLink
    }
}
