//
//  TrendingManager.swift
//  GithubSearch
//
//  Created by Tarokh on 8/10/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import Foundation
import Alamofire

protocol GithubManagerDelegate {
    func didFailed(error: Error)
    func updateTrending(trendingModel: [Items])
}

class GithubManager {
    
    // define some variables
    var githubItems = [Items]()
    var delegate: GithubManagerDelegate?
    
    // define some functions
    func getTrending() {
        let url = Routes.trendingURL + "&q=language:swift,java"
        performRequest(with: url)
    }
    
    func getTrending(name: String) {
        let url = Routes.trendingURL + "&q=\(name)"
        performRequest(with: url)
    }
    
    func performRequest(with urlString: String) {
        let request = AF.request(urlString)
        request.responseData { (result) in
            if let safeData = result.data {
                if let trending = self.fetchJSON(trendingData: safeData) {
                    self.delegate?.updateTrending(trendingModel: trending)
                    print(safeData.count)
                }
            }
        }
    }
    
    func fetchJSON(trendingData: Data) -> [Items]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(GithubData.self, from: trendingData)
            //print(decodedData)
            for trendingInformation in decodedData.items {
                let id = trendingInformation.id
                let full_name = trendingInformation.full_name
                let html_url = trendingInformation.html_url
                let description = trendingInformation.description
                githubItems.append(Items(id: id, full_name: full_name, html_url: html_url, description: description))
                print("Trending item are: \(githubItems.count)")
            }
            return githubItems
            
        }catch let jsonError as NSError {
            self.delegate?.didFailed(error: jsonError)
        }
        return []
    }
    
}
