//
//  UserListViewController.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/12/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit
import Swinject
import RxSwift

class UserListViewController: UITableViewController {
    
    var viewModel: UserListModelType?
    var dependencyContainer: Container? // TODO: i don't like this as nobody knows what services are required to handle
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl();
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100
        
        self.title = self.viewModel!.listTitle
        
        self.viewModel!.updateUserList()
            .subscribe(
                onNext: { (result) in
                    self.tableView.reloadData()
                },
                onError: { (error) in
                    print("Error while retrieving users, \(error)")
                }
            )
            .addDisposableTo(self.disposeBag)
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
        let shouldDisplayLoadMore = self.viewModel!.moreFollowersAreAvailableToLoad
        return self.viewModel!.numberOfRowsInTableView() + (shouldDisplayLoadMore ? 1 : 0)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard (indexPath.row < self.viewModel!.numberOfRowsInTableView()) else {
            return self.tableView!.dequeueReusableCellWithIdentifier("LoadMoreCell")!
        }
        
        let cell = self.tableView!.dequeueReusableCellWithIdentifier(String(UserListTableViewCell)) as! UserListTableViewCell
        if let model = self.viewModel!.modelForRow(atIndexPath: indexPath) {
            cell.setDataFromModel(model, imageLoadingService: dependencyContainer!.resolve(AsyncImageLoadingServiceType.self)!)
        }
        return cell
    }
}

// UITableViewDelegate
extension UserListViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard (indexPath.row < self.viewModel!.numberOfRowsInTableView()) else {
            self.viewModel!.loadMoreUsers()
                .subscribe(
                    onNext: { (result) in
                        if (result) {
                            self.tableView.reloadData()
                        }
                    },
                    onError: { (error) in
                        print("Error while retrieving more users, \(error)")
                    }
                )
                .addDisposableTo(self.disposeBag)
            return
        }
        
        self.viewModel!.selectRow(atIndexPath: indexPath)
    }
}