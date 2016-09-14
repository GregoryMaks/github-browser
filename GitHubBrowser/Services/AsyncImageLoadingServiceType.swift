//
//  AsyncImageLoadingServiceType.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/14/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit

protocol AsyncImageLoadingServiceType {

    func loadImageAsynchronously (atUrl imageUrl: NSURL,
                                        onQueue: dispatch_queue_t,
                                        completionBlock: (resultImage: UIImage?, error: NSError?) -> Void)
    func cancelImageLoading ()
}
