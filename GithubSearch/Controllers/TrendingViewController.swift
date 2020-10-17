//
//  TrendingViewController.swift
//  GithubSearch
//
//  Created by Tarokh on 8/10/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreData
import SVProgressHUD

class TrendingViewController: UIViewController {

    //MARK: - @IBOutlets
    @IBOutlet var trendingTableView: UITableView!
    
    
    //MARK: - Variables
    var trendingItems = GithubManager()
    var hud: MBProgressHUD?
    
    
    //MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        trendingTableView.isHidden = true
        trendingTableView.estimatedRowHeight = 100
        trendingTableView.rowHeight = UITableView.automaticDimension
        trendingTableView.register(UINib(nibName: "TrendingCell", bundle: nil), forCellReuseIdentifier: "trendingCell")
        trendingTableView.delegate = self
        trendingTableView.dataSource = self
        
        trendingItems.delegate = self
        trendingItems.getTrending()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    //MARK: - Functions
    private func save(name: String, desc: String, url: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Github", in: managedContext)
        let favorites = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        favorites.setValue(name, forKey: "fullName")
        favorites.setValue(desc, forKey: "desc")
        favorites.setValue(url, forKey: "htmlURL")
        
        do {
            print("Data saved")
            try managedContext.save()
            hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud?.mode = .customView
            let image = UIImage(named: "checkmark")
            hud?.customView = UIImageView(image: image!)
            hud?.isSquare = true
            hud?.label.text = "Added to your favorite!"
            hud?.hide(animated: true, afterDelay: 3.0)
            
        }catch let error as NSError {
            print("Could not save data: \(error.localizedDescription)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToURL" {
            let webVC = segue.destination as? WebController
            let indexPath = self.trendingTableView.indexPathForSelectedRow
            let urlItem = trendingItems.githubItems[indexPath!.row]
            webVC?.url = urlItem.html_url
        }
    }

}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension TrendingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("The number of items are: \(trendingItems.githubItems.count)")
        return trendingItems.githubItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trendingCell") as! TrendingCell
        let item = trendingItems.githubItems[indexPath.row]
        cell.configCell(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let bookmarkItem = UIContextualAction(style: .normal, title: "Add to favorite") { (action, view, completionHandler) in
            let trendingItem = self.trendingItems.githubItems[indexPath.row]
            self.save(name: trendingItem.full_name, desc: trendingItem.description, url: trendingItem.html_url)
            completionHandler(true)
        }
        
        bookmarkItem.image = UIImage(systemName: "bookmark.fill")
        bookmarkItem.image?.withTintColor(.white)
        bookmarkItem.backgroundColor = UIColor(rgb: 0x1F4068)
        
        let swipeActions = UISwipeActionsConfiguration(actions: [bookmarkItem])
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToURL", sender: self)
    }

    
}

//MARK: - TrendingManagerDelegate
extension TrendingViewController: GithubManagerDelegate {
    
    
    func updateTrending(trendingModel: [Items]) {
        DispatchQueue.main.async {
            self.trendingTableView.isHidden = false
            MBProgressHUD.hide(for: self.view, animated: true)
            self.trendingTableView.reloadData()
        }
    }
    
    
    func didFailed(error: Error) {
        print(error.localizedDescription)
    }
    
    
}
