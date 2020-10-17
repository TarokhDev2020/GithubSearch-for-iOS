//
//  TrendingData.swift
//  GithubSearch
//
//  Created by Tarokh on 8/10/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import Foundation

struct GithubData: Codable {
    
    // define some variables
    let items: [Items]
    
}

struct Items: Codable {
    
    let id: Int
    let full_name: String
    let html_url: String
    let description: String
    
}
