//
//  UserListModel.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/13/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit

class UserListModel: UserListModelType {
    
    var username: String?
    var previousUsersList: [String]
    
    var listTitle: String {
        get {
            return username ?? "GitHub users"
        }
    }
    
    // Private
    var tempData: [GithubUserModel]
    
    convenience init () {
        self.init(username: nil, previousUsersList: [])
    }
    
    required init (username: String?, previousUsersList: [String]) {
        self.username = username
        self.previousUsersList = previousUsersList
        
        // TODO temp
        self.tempData = [GithubUserModel(username: "Tom", avatarUrl: NSURL(string:"https://pigroll.com/img/work_and_travel.jpg"), githubLink: NSURL(string:"www.github.com/user/tom")!),
                         GithubUserModel(username: "John", avatarUrl: NSURL(string:"https://pigroll.com/img/work_and_travel.jpg"), githubLink: NSURL(string:"www.github.com/user/john")!),
                         GithubUserModel(username: "Jerry", avatarUrl: NSURL(string:"https://pigroll.com/img/work_and_travel.jpg"), githubLink: NSURL(string:"www.github.com/user/jerry")!)]
    }
    
    func numberOfRowsInTableView () -> Int {
        return self.tempData.count
    }
    
    func modelForRow (atIndexPath indexPath:NSIndexPath) -> GithubUserModel {
        return self.tempData[indexPath.row]
    }
}

private extension UserListModel {
    // TODO
}