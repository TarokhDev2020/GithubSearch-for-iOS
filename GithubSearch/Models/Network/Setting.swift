//
//  Setting.swift
//  GithubSearch
//
//  Created by Tarokh on 8/10/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import Foundation

class GlobalSetting {
    static let shared = GlobalSetting()
}

struct Routes {
    static let s = GlobalSetting.shared
    static let query = "q=language:swift"
    static let order = "order=desc"
    static let sort = "sort=stars"
    static let trendingURL = "https://api.github.com/search/repositories?\(sort)&\(order)"
}

