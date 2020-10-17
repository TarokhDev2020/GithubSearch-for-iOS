//
//  WebController.swift
//  GithubSearch
//
//  Created by Tarokh on 8/11/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import UIKit
import WebKit

class WebController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet var mainWebView: WKWebView!
    
    
    //MARK: - Variables
    var url: String?
    

    //MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()

        print("The url is: \(url!)")
        mainWebView.load(URLRequest(url: URL(string: url!)!))
    }
    

}
