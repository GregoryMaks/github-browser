//
//  UserListModelType.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/13/16.
//  Copyright © 2016 None. All rights reserved.
//

import Foundation
import RxSwift

protocol UserListModelType {
    
    var listTitle: String { get }
    var userModel: GithubUserModel? { get }
    
    var moreFollowersAreAvailableToLoad: Bool { get }
    var isDataLoading: Variable<Bool> { get }
    
    weak var coordinatorDelegate: UserListModelCoordinatorDelegate? { get set }
    
    /// - Parameter userService: point for DI
    /// - Parameter userModel: represents user whose followers we'd like to show, may be nil to show all root users
    init (userService: GithubUsersServiceType, userModel: GithubUserModel?)
    
    func numberOfRowsInTableView () -> Int
    func modelForRow (atIndexPath indexPath:NSIndexPath) -> GithubUserModel?
    
    func updateUserList () -> Observable<Bool>
    func loadMoreUsers () -> Observable<Bool>
    
    func selectRow (atIndexPath indexPath:NSIndexPath)
}