//
//  UserListViewController.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/12/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit
import Swinject

class UserListViewController: UITableViewController {
    
    var viewModel: UserListModelType?
    var dependencyContainer: Container? // TODO: i don't like this as nobody knows what services are required to handle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl();
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100
        
        self.title = self.viewModel!.listTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// UITableViewDataSource
extension UserListViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel!.numberOfRowsInTableView()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView!.dequeueReusableCellWithIdentifier(String(UserListTableViewCell)) as! UserListTableViewCell
        
        let model = self.viewModel!.modelForRow(atIndexPath: indexPath)
        cell.setDataFromModel(model, imageLoadingService: dependencyContainer!.resolve(AsyncImageLoadingServiceType.self)!)
        
        return cell
    }
}

// UITableViewDelegate
extension UserListViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("row tapped")
    }
}