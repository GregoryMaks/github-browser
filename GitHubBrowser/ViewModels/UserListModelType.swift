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
    var username: String? { get }
    var previousUsersList: [String]? { get }
    
    weak var coordinatorDelegate: UserListModelCoordinatorDelegate? { get set }
    
    /// - Parameter userService: point for DI
    /// - Parameter username: represents user whose followers we'd like to show, may be nil to show all root users
    /// - Parameter previousUsersList: is the user list from which we got to this step, designated to track the history of steps
    init (userService: GithubUserServiceType, username: String?, previousUsersList: [String]?)
    
    func numberOfRowsInTableView () -> Int
    func modelForRow (atIndexPath indexPath:NSIndexPath) -> GithubUserModel?
    
    func updateUserList () -> Observable<Bool>
    func loadMoreUsers () -> Observable<Bool>
    
    func selectRow (atIndexPath indexPath:NSIndexPath)
}