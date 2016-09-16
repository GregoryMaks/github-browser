//
//  UserListCoordinator.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/13/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit
import Swinject

class UserListCoordinator: Coordinator {
 
    var window: UIWindow
    var storyboardDIContainer: Container
    var storyboard: SwinjectStoryboard?
    
    var navigationController: UINavigationController?
    
    var previousListVC: UserListViewController?
    var currentUserListVC: UserListViewController?
    
    var followersUserListCoordinator: UserListCoordinator?
    
    init (window: UIWindow) {
        self.window = window
        
        self.storyboardDIContainer = Container()
        self.storyboardDIContainer.registerForStoryboard(UserListViewController.self) { resolver, viewController in
            viewController.viewModel = resolver.resolve(UserListModelType.self)
            
            // TODO rewrite, kingfisher for image loading??
            viewController.dependencyContainer = Container()
            viewController.dependencyContainer?.register(AsyncImageLoadingServiceType.self) {
                _ in AsyncImageLoadingService()
            }
        }
        self.storyboardDIContainer.register(GithubUserServiceType.self) {
            _ in GithubUserService()
        }
        self.storyboardDIContainer.register(UserListModelType.self) { (resolver) in
            let viewModel = UserListModel(userService: resolver.resolve(GithubUserServiceType.self)!)
            viewModel.coordinatorDelegate = self
            return viewModel
        }
        
        self.storyboard = SwinjectStoryboard.create(name:"Main", bundle:NSBundle.mainBundle(), container: self.storyboardDIContainer);
    }
    
    func start() {
        self.navigationController = (self.storyboard!.instantiateViewControllerWithIdentifier("RootNavigationControllerIdentifier") as! UINavigationController)
        self.currentUserListVC = (self.navigationController?.topViewController as? UserListViewController)
        
        self.window.rootViewController = self.navigationController;
    }
}

extension UserListCoordinator : UserListModelCoordinatorDelegate {

    func userListViewModelShouldNavigateToFollowers (ofUser userModel: GithubUserModel) {
        self.pushUserListViewVC(ofUser: userModel)
    }
}

private extension UserListCoordinator {
    
    func pushUserListViewVC (ofUser newUserModel: GithubUserModel) {
        print("push new controller for \(newUserModel.username)")
        
        self.previousListVC = self.currentUserListVC
        
        let previousUser = self.previousListVC!.viewModel!.userModel
        let userVisitHistory = self.previousListVC!.viewModel!.previousUsersModels
        let newUserListVC = self.createUserListVCForNewUser(newUser: newUserModel,
                                                            previousUser: previousUser,
                                                            previousUserModelsHistory: userVisitHistory)
        
        self.currentUserListVC = newUserListVC
        
        self.navigationController?.pushViewController(self.currentUserListVC!, animated: true)
    }
    
    func popTopmostUserListVC () {
        // TODO
    }
    
    func createUserListVCForNewUser (newUser      newUserModel: GithubUserModel,
                                     previousUser previousUserModel: GithubUserModel?,
                                                  previousUserModelsHistory: [GithubUserModel]?) -> UserListViewController {
        
        // Constructing user history
        var userVisitHistory = [GithubUserModel]()
        if let previousUsersModels = self.previousListVC!.viewModel!.previousUsersModels {
            userVisitHistory.appendContentsOf(previousUsersModels)
        }
        if let previousUser = self.previousListVC!.viewModel!.userModel {
            userVisitHistory.append(previousUser)
        }
        
        self.storyboardDIContainer.register(UserListModelType.self) { (resolver) in
            let viewModel = UserListModel(userService: resolver.resolve(GithubUserServiceType.self)!,
                                          userModel: newUserModel,
                                          previousUsersModels: userVisitHistory)
            viewModel.coordinatorDelegate = self
            return viewModel
        }
        
        return self.storyboard!.instantiateViewControllerWithIdentifier("UserListViewControllerIdentifier") as! UserListViewController
    }
}