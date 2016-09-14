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
    var userListVC: UserListViewController?
    
    init (window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let diContainer = Container()
        diContainer.registerForStoryboard(UserListViewController.self) { resolver, viewController in
            viewController.viewModel = resolver.resolve(UserListModelType.self)
            viewController.dependencyContainer = Container()
            viewController.dependencyContainer?.register(AsyncImageLoadingServiceType.self) {
                _ in AsyncImageLoadingService()
            }
        }
        diContainer.register(UserListModelType.self) {
            _ in UserListModel()
        }
        
        let storyboard = SwinjectStoryboard.create(name:"Main", bundle:NSBundle.mainBundle(), container: diContainer);
        
        self.navigationController = (storyboard.instantiateViewControllerWithIdentifier("RootNavigationControllerIdentifier") as! UINavigationController)
        self.userListVC = (self.navigationController?.topViewController as? UserListViewController)
        
        self.window.rootViewController = self.navigationController;
    }
}


