//
//  UserListTableViewCell.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/14/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit

class UserListTableViewCell: UITableViewCell {
    
    private var avatarImageUrl: NSURL?
    private var imageLoadingService: AsyncImageLoadingServiceType?
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    func setDataFromModel (model: GithubUserModel, imageLoadingService: AsyncImageLoadingServiceType) {
        self.usernameLabel.text = model.username
        self.urlLabel.text = model.githubLink.absoluteString
        
        self.imageLoadingService = imageLoadingService
        self.avatarImageUrl = model.avatarUrl
        
        loadAvatarImage()
    }
    
    private func loadAvatarImage () {
        guard (self.userAvatarImageView.image == nil) else {
            return
        }
        guard (self.imageLoadingService != nil && self.avatarImageUrl != nil) else {
            return
        }
        
        self.imageLoadingService?.cancelImageLoading()
        self.imageLoadingService?.loadImageAsynchronously(atUrl: self.avatarImageUrl!,
                                                          onQueue: dispatch_get_main_queue(),
                                                          completionBlock: { (resultImage, error) in
                                                            guard (error == nil) else {
                                                                print("Error loading image from URL: \(self.avatarImageUrl)")
                                                                return
                                                            }
                                                            
                                                            self.userAvatarImageView.image = resultImage
        })
    }
    
    override func prepareForReuse() {
        self.imageLoadingService?.cancelImageLoading()
        self.userAvatarImageView.image = nil
    }
}
