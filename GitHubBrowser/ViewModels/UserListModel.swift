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
    
    var userModel: GithubUserModel?
    var listTitle: String {
        get {
            return userModel?.username ?? "GitHub users"
        }
    }
    weak var coordinatorDelegate: UserListModelCoordinatorDelegate?
    
    private var userService: GithubUserServiceType
    private var followerUsersModels: [GithubUserModel]?
    
    required init (userService: GithubUserServiceType, userModel: GithubUserModel? = nil) {
        self.userModel = userModel
        
        self.userService = userService
    }
    
    func numberOfRowsInTableView () -> Int {
        return self.followerUsersModels != nil ? self.followerUsersModels!.count : 0;
    }
    
    func modelForRow (atIndexPath indexPath:NSIndexPath) -> GithubUserModel? {
        return self.followerUsersModels?[indexPath.row];
    }
    
    func updateUserList () -> Observable<Bool> {
        return self.retrieveUserListPart(nil, itemsPerPage: GithubUserServiceBatchSize.Default)
            .doOnNext({ (models) in
                self.followerUsersModels = models
            })
            .map({ (models) -> Bool in
                return true
            });
    }
    
    func loadMoreUsers () -> Observable<Bool> {
        let lastUserId: Int? = self.followerUsersModels?.last?.id
        
        return self.retrieveUserListPart(lastUserId, itemsPerPage: GithubUserServiceBatchSize.Default)
            .doOnNext({ (models) in
                self.followerUsersModels?.appendContentsOf(models)
            })
            .map({ (models) -> Bool in
                return true
            });
    }
    
    func selectRow (atIndexPath indexPath:NSIndexPath) {
        if let userModel = self.modelForRow(atIndexPath: indexPath) {
            self.coordinatorDelegate?.userListViewModelShouldNavigateToFollowers(ofUser: userModel)
        }
    }
}

private extension UserListModel {
    
    func retrieveUserListPart (sinceId: Int?, itemsPerPage: GithubUserServiceBatchSize) -> Observable<[GithubUserModel]> {
        return Observable.create({ (observer: AnyObserver<[GithubUserModel]>) -> Disposable in
            
            if (self.userModel?.username == nil) {
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
                self.userService.retrieveFollowersList(self.userModel!.followersLink,
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
            }
            
            return NopDisposable.instance
        })
    }
}