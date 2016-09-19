//
//  UserListCoordinator.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/13/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit
import Swinject

class UserListCoordinator: NSObject, Coordinator {
 
    var window: UIWindow
    private var storyboardDIContainer: Container?
    private var storyboard: SwinjectStoryboard?
    
    private var originalNavigationBarDelegate: UINavigationBarDelegate?
    private var navigationController: UINavigationController?
    
    private var previousUserListVC: UserListViewController?
    private var currentUserListVC: UserListViewController?
    
    /// Holds all users that were visited prior to current user (current user in not included in the list)
    private var userModelsVisitHistory: [GithubUserModel]
    
    
    required init (window: UIWindow) {
        self.window = window
        self.userModelsVisitHistory = [GithubUserModel]()
        
        super.init()
        
        self.storyboardDIContainer = Container()
        self.storyboardDIContainer!.registerForStoryboard(UserListViewController.self) { resolver, viewController in
            viewController.viewModel = resolver.resolve(UserListModelType.self)
            
            // TODO rewrite, kingfisher for image loading??
            viewController.dependencyContainer = Container()
            viewController.dependencyContainer?.register(AsyncImageLoadingServiceType.self) {
                _ in AsyncImageLoadingService()
            }
        }
        self.storyboardDIContainer!.register(GithubAllUsersService.self) {
            _ in GithubAllUsersService()
        }
        
        // TODO: do I need it? Even if self is :NSObject
        weak var weakSelf: UserListCoordinator? = self
        self.storyboardDIContainer!.register(UserListModelType.self) { (resolver) in
            let viewModel = UserListModel(userService: resolver.resolve(GithubAllUsersService.self)!)
            viewModel.coordinatorDelegate = weakSelf
            return viewModel
        }
        
        self.storyboard = SwinjectStoryboard.create(name:"Main", bundle:NSBundle.mainBundle(), container: self.storyboardDIContainer!);
    }
    
    func start() {
        self.navigationController = (self.storyboard!.instantiateViewControllerWithIdentifier("RootNavigationControllerIdentifier") as! UINavigationController)
        self.currentUserListVC = (self.navigationController?.topViewController as? UserListViewController)
        
        // Special hack to normalize navigationBar animation, don't like this, but who does
        self.originalNavigationBarDelegate = self.navigationController?.navigationBar.delegate
        self.navigationController?.navigationBar.delegate = self
        
        self.window.rootViewController = self.navigationController;
    }
}

extension UserListCoordinator : UserListModelCoordinatorDelegate {

    func userListViewModelShouldNavigateToFollowers (ofUser userModel: GithubUserModel) {
        self.pushUserListViewVC(ofUser: userModel)
    }
}

// TODO: can this be optimized by using delegate proxy or method forwarding? Research.
extension UserListCoordinator : UINavigationBarDelegate {
    
    func navigationBar(navigationBar: UINavigationBar, shouldPushItem item: UINavigationItem) -> Bool {
        return self.originalNavigationBarDelegate?.navigationBar?(navigationBar, shouldPushItem: item) ?? true
    }
    func navigationBar(navigationBar: UINavigationBar, didPushItem item: UINavigationItem) {
        self.originalNavigationBarDelegate?.navigationBar?(navigationBar, didPushItem: item)
    }
    func navigationBar(navigationBar: UINavigationBar, shouldPopItem item: UINavigationItem) -> Bool {
        return self.originalNavigationBarDelegate?.navigationBar?(navigationBar, shouldPopItem: item) ?? true
    }
    
    func navigationBar(navigationBar: UINavigationBar, didPopItem item: UINavigationItem) {
        self.originalNavigationBarDelegate?.navigationBar?(navigationBar, didPopItem: item)
        
        self.processTopmostUserListVCPop()
    }
}

private extension UserListCoordinator {
    
    func pushUserListViewVC (ofUser newUserModel: GithubUserModel) {
        print("push new controller for \(newUserModel.username)")
        
        if let currentUser = self.currentUserListVC!.viewModel!.userModel {
            self.userModelsVisitHistory.append(currentUser)
        }
        
        let newUserListVC = self.createUserListVCForNewUser(newUser: newUserModel)
        
        self.previousUserListVC = self.currentUserListVC
        self.currentUserListVC = newUserListVC
        
        self.navigationController?.setViewControllers([self.previousUserListVC!, self.currentUserListVC!], animated: true)
    }
    
    func processTopmostUserListVCPop () {
        print("pop view controller")
        
        // Pop already occured, processing changes
        self.currentUserListVC = self.previousUserListVC
        
        if (self.userModelsVisitHistory.count == 0) {
            // Nowhere to pop afterwards, we're at the very bottom
            self.previousUserListVC = nil;
        }
        else {
            // Current UserListVC will contain this user, remove it
            self.userModelsVisitHistory.removeLast()
            
            var historyCreatedUserListVC: UserListViewController
            if let historyPredecessorUser = self.userModelsVisitHistory.last {
                historyCreatedUserListVC = self.createUserListVCForNewUser(newUser: historyPredecessorUser)
            }
            else {
                historyCreatedUserListVC = self.createUserListVCForAllUsers()
            }
            
            self.currentUserListVC = self.previousUserListVC;
            self.previousUserListVC = historyCreatedUserListVC;
        }
        
        var viewControllers = [UIViewController]()
        if (self.previousUserListVC != nil) {
            viewControllers.append(self.previousUserListVC!)
        }
        viewControllers.append(self.currentUserListVC!)
        
        self.navigationController?.setViewControllers(viewControllers, animated: false)
    }
    
    func createUserListVCForAllUsers () -> UserListViewController {
        self.storyboardDIContainer!.register(UserListModelType.self) { (resolver) in
            let viewModel = UserListModel(userService: resolver.resolve(GithubAllUsersService.self)!)
            viewModel.coordinatorDelegate = self
            return viewModel
        }
        
        return self.storyboard!.instantiateViewControllerWithIdentifier("UserListViewControllerIdentifier") as! UserListViewController
    }
    
    func createUserListVCForNewUser (newUser newUserModel: GithubUserModel) -> UserListViewController {
        
        self.storyboardDIContainer!.register(UserListModelType.self) { (resolver) in
            let viewModel = UserListModel(userService: resolver.resolve(GithubFollowersUsersService.self)!,
                                          userModel: newUserModel)
            viewModel.coordinatorDelegate = self
            return viewModel
        }
        self.storyboardDIContainer!.register(GithubFollowersUsersService.self) {
            _ in GithubFollowersUsersService(user: newUserModel)
        }
        
        return self.storyboard!.instantiateViewControllerWithIdentifier("UserListViewControllerIdentifier") as! UserListViewController
    }
}