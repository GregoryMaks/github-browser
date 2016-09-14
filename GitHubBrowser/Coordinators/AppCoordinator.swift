//
//  AppCoordinator.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/12/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit

class AppCoordinator : Coordinator {
    
    var window: UIWindow
    var rootUserListCoordinator: UserListCoordinator?
    
    init (window: UIWindow) {
        self.window = window
    }
    
    func start() {
        showRootUserList()
    }
}

private extension AppCoordinator {
    
    private func showRootUserList () {
        self.rootUserListCoordinator = UserListCoordinator(window: self.window)
        self.rootUserListCoordinator!.start()
    }
}
