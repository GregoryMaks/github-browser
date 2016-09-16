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
    var navigationController: UINavigationController?
    
    var previousListVC: UserListViewController?
    var currentUserListVC: UserListViewController?
    
    var followersUserListCoordinator: UserListCoordinator?
    
    init (window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let diContainer = Container()
        diContainer.registerForStoryboard(UserListViewController.self) { resolver, viewController in
            viewController.viewModel = resolver.resolve(UserListModelType.self)
            
            // TODO rewrite, kingfisher for image loading??
            viewController.dependencyContainer = Container()
            viewController.dependencyContainer?.register(AsyncImageLoadingServiceType.self) {
                _ in AsyncImageLoadingService()
            }
        }
        diContainer.register(GithubUserServiceType.self) {
            _ in GithubUserService()
        }
        diContainer.register(UserListModelType.self) { (resolver) in
            let viewModel = UserListModel(userService: resolver.resolve(GithubUserServiceType.self)!)
            viewModel.coordinatorDelegate = self
            return viewModel
        }

        let storyboard = SwinjectStoryboard.create(name:"Main", bundle:NSBundle.mainBundle(), container: diContainer);
        
        self.navigationController = (storyboard.instantiateViewControllerWithIdentifier("RootNavigationControllerIdentifier") as! UINavigationController)
        self.currentUserListVC = (self.navigationController?.topViewController as? UserListViewController)
        
        self.window.rootViewController = self.navigationController;
    }
}

extension UserListCoordinator : UserListModelCoordinatorDelegate {

    func userListViewModelShouldNavigateToFollowers (ofUser userModel: GithubUserModel) {

        print("push new controller for \(userModel.username)")
//        self.followersUserListCoordinator = UserListCoordinator(window: self.window)
//        self.followersUserListCoordinator!.start()
    }
}

private extension UserListCoordinator {
    
    func pushUserListViewVC (ofUser userModel: GithubUserModel) {
    }
}