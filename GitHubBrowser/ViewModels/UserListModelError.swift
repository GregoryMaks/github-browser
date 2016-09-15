//
//  UserListModelError.swift
//  GitHubBrowser
//
//  Created by GregoryM on 9/15/16.
//  Copyright © 2016 None. All rights reserved.
//

import UIKit

enum UserListModelError: ErrorType {
    case InnerError(NSError)
    case EmptyData
    case Unknown
}
