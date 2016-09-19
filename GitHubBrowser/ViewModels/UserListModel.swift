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
    
    var moreFollowersAreAvailableToLoad: Bool
    
    weak var coordinatorDelegate: UserListModelCoordinatorDelegate?
    
    private var userService: GithubUsersServiceType
    private var userServicePagingMarker: GithubUsersPagingMarkerType?
    private var followerUsersModels: [GithubUserModel]?
    
    
    required init (userService: GithubUsersServiceType, userModel: GithubUserModel? = nil) {
        self.userService = userService
        self.userModel = userModel
        
        self.moreFollowersAreAvailableToLoad = true
    }
    
    func numberOfRowsInTableView () -> Int {
        return self.followerUsersModels != nil ? self.followerUsersModels!.count : 0;
    }
    
    func modelForRow (atIndexPath indexPath:NSIndexPath) -> GithubUserModel? {
        return self.followerUsersModels?[indexPath.row];
    }
    
    func updateUserList () -> Observable<Bool> {
        return self.retrieveUserListPart(nil)
            .doOnNext({ (models, pagingMarker) in
                self.userServicePagingMarker = pagingMarker
                self.followerUsersModels = models
            })
            .map({ (models) -> Bool in
                return true
            });
    }
    
    func loadMoreUsers () -> Observable<Bool> {
        return self.retrieveUserListPart(self.userServicePagingMarker)
            .doOnNext({ (models, pagingMarker) in
                guard (models.count != 0) else {
                    self.moreFollowersAreAvailableToLoad = false
                    return
                }
                self.userServicePagingMarker = pagingMarker
                self.followerUsersModels?.appendContentsOf(models)
            })
            .map({ (models, pagingMarker) -> Bool in
                return models.count > 0
            });
    }
    
    func selectRow (atIndexPath indexPath:NSIndexPath) {
        if let userModel = self.modelForRow(atIndexPath: indexPath) {
            self.coordinatorDelegate?.userListViewModelShouldNavigateToFollowers(ofUser: userModel)
        }
    }
}

private extension UserListModel {
    
    func retrieveUserListPart (pagingMarker: GithubUsersPagingMarkerType?)
        -> Observable<([GithubUserModel], GithubUsersPagingMarkerType?)> {
        
        return Observable.create({ (observer: AnyObserver<([GithubUserModel], GithubUsersPagingMarkerType?)>) -> Disposable in
            self.userService.retrieveUserList(pagingMarker) { (models, pagingMarker, error) in
                guard (error == nil) else {
                    observer.on(.Error(error!))
                    return
                }
                
                guard models != nil else {
                    observer.on(.Error(UserListModelError.EmptyData))
                    return
                }
                
                observer.on(.Next((models!, pagingMarker)))
            }
            
            return NopDisposable.instance
        })
    }
}