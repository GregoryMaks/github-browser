//
//  AsyncImageLoadingService.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/14/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit

/// Simplest controllable way to load an image
// TODO rewrite, maybe user kingfisher for image loading??
class AsyncImageLoadingService : AsyncImageLoadingServiceType {
    
    private var imageLoadingTask: NSURLSessionDataTask?
    
    func loadImageAsynchronously (atUrl imageUrl: NSURL,
                                        onQueue: dispatch_queue_t,
                                        completionBlock: (resultImage: UIImage?, error: NSError?) -> Void) {
        
        self.imageLoadingTask = NSURLSession.sharedSession().dataTaskWithURL(imageUrl, completionHandler: {
            (imageData, response, error) in
            
            if (imageData != nil && error == nil) {
                if let image = UIImage(data:imageData!) {
                    dispatch_async(onQueue, {
                        completionBlock(resultImage:image, error:nil)
                    });
                    return;
                }
            }
            
            dispatch_async(onQueue, {
                completionBlock(resultImage: nil, error: error)
            });
        });
        
        self.imageLoadingTask?.resume()
    }
    
    func cancelImageLoading () {
        self.imageLoadingTask?.cancel()
    }
    
    deinit {
        cancelImageLoading()
    }
}
