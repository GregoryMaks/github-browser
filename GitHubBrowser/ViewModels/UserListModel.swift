//
//  UserListModel.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/13/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit
import RxSwift


class UserListModel: UserListModelType {
    
    var username: String?
    var previousUsersList: [String]?
    
    var listTitle: String {
        get {
            return username ?? "GitHub users"
        }
    }
    
    private var userService: GithubUserServiceType
    private var userFollowersUrl: NSURL?
    private var userModels: [GithubUserModel]?
    
    required init (userService: GithubUserServiceType, username: String? = nil, previousUsersList: [String]? = nil) {
        self.username = username
        self.previousUsersList = previousUsersList
        
        self.userService = userService
    }
    
    func numberOfRowsInTableView () -> Int {
        return self.userModels != nil ? self.userModels!.count : 0;
    }
    
    func modelForRow (atIndexPath indexPath:NSIndexPath) -> GithubUserModel? {
        return self.userModels?[indexPath.row];
    }
    
    func updateUserList () -> Observable<Bool> {
        return self.retrieveUserListPart(nil, itemsPerPage: GithubUserServiceBatchSize.Default)
            .doOnNext({ (models) in
                self.userModels = models
            })
            .map({ (models) -> Bool in
                return true
            });
    }
    
    func loadMoreUsers () -> Observable<Bool> {
        let lastUserId: Int? = self.userModels?.last?.id
        
        return self.retrieveUserListPart(lastUserId, itemsPerPage: GithubUserServiceBatchSize.Default)
            .doOnNext({ (models) in
                self.userModels?.appendContentsOf(models)
            })
            .map({ (models) -> Bool in
                return true
            });
    }
}

private extension UserListModel {
    
    func retrieveUserListPart (sinceId: Int?, itemsPerPage: GithubUserServiceBatchSize) -> Observable<[GithubUserModel]> {
        return Observable.create({ (observer: AnyObserver<[GithubUserModel]>) -> Disposable in
            
            if (self.username == nil) {
                self.userService.retrieveGlobalUserList(sinceId, itemsPerPage: itemsPerPage) { (models, error) in
                    guard (error == nil) else {
                        observer.on(.Error(error!))
                        return
                    }
                    
                    guard models != nil else {
                        observer.on(.Error(UserListModelError.EmptyData))
                        return
                    }
                    
                    observer.on(.Next(models!))
                }
            }
            else {
                self.followersUrlForUser(self.username!, completionHandler: { (followersUrl, error) in
                    guard error == nil else {
                        observer.on(.Error(error!))
                        return
                    }
                    
                    self.userService.retrieveFollowersList(followersUrl!,
                        sinceId: sinceId,
                        itemsPerPage: itemsPerPage,
                        completionHandler: { (models, error) in
                            guard (error == nil) else {
                                observer.on(.Error(UserListModelError.InnerError(error!)))
                                return
                            }
                            guard models != nil else {
                                observer.on(.Error(UserListModelError.EmptyData))
                                return
                            }
                            
                            observer.on(.Next(models!))
                    })
                })
            }
            
            return NopDisposable.instance
        })
    }
    
    func followersUrlForUser (username: String, completionHandler: (followersUrl: NSURL?, error: UserListModelError?) -> Void) -> Void {
        
        if (self.userFollowersUrl != nil) {
            completionHandler(followersUrl: self.userFollowersUrl, error: nil)
        }
        else {
            self.userService.retreiveUserData(self.username!, completionHandler: { (userModel, error) in
                guard (error == nil) else {
                    completionHandler(followersUrl: nil, error: UserListModelError.InnerError(error!))
                    return
                }
                
                let followersUrl = userModel?.followersLink
                guard (followersUrl != nil) else {
                    completionHandler(followersUrl: nil, error: UserListModelError.EmptyData)
                    return
                }
            
                self.userFollowersUrl = followersUrl
                completionHandler(followersUrl: self.userFollowersUrl, error: nil)
            })
        }
    }
}