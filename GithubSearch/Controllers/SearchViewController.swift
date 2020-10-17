//
//  SearchViewController.swift
//  GithubSearch
//
//  Created by Tarokh on 8/10/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import MBProgressHUD
import CoreData

class SearchViewController: UIViewController, UISearchResultsUpdating {
    
    //MARK: - @IBOutlets
    @IBOutlet var searchTableView: UITableView!
    
    
    
    //MARK: - Variables
    var searchController: UISearchController?
    let searchManager = GithubManager()
    var hud: MBProgressHUD?
    
    
    //MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTableView.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "searchCell")
        
        searchTableView.separatorStyle = .none
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.emptyDataSetSource = self
        searchTableView.emptyDataSetDelegate = self
        
        searchManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(SearchViewController.search))
        searchButton.tintColor = .white
        tabBarController?.navigationItem.rightBarButtonItem = searchButton
        definesPresentationContext = true
    }
    
    //MARK: - Functions
    @objc func search() {
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.delegate = self
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.searchBar.placeholder = "Type something..."
        searchController?.searchBar.autocapitalizationType = .none
        self.present(searchController!, animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {return}
        print("The search item is: \(text)")
    }

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
            //hud?.label.text = "Added to your favorite!"
            hud?.hide(animated: true, afterDelay: 3.0)
        }catch let jsonError as NSError {
            print("Could not save data: \(jsonError.localizedDescription)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToURL" {
            let webVC = segue.destination as? WebController
            let indexPath = self.searchTableView.indexPathForSelectedRow
            let urlItem = searchManager.githubItems[indexPath!.row]
            webVC?.url = urlItem.html_url
        }
    }

}


//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchManager.githubItems = []
        MBProgressHUD.showAdded(to: self.view, animated: true)
        self.dismiss(animated: true, completion: nil)
        guard let text = searchBar.text else {return}
        self.searchManager.getTrending(name: text)
    }
    
}

//MARK: - DZNEmptyDataSource, DZNEmptyDataDelegate
extension SearchViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView?) -> NSAttributedString? {
        let text = "Tap the search icon to search!"

        let attributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }

    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchManager.githubItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchCell
        let item = searchManager.githubItems[indexPath.row]
        cell.configCell(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let bookmarkItem = UIContextualAction(style: .normal, title: "Add to favorite") { (action, view, completionHandler) in
            let searchItems = self.searchManager.githubItems[indexPath.row]
            self.save(name: searchItems.full_name, desc: searchItems.description, url: searchItems.description)
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
extension SearchViewController: GithubManagerDelegate {
    
    func didFailed(error: Error) {
        print(error.localizedDescription)
    }
    
    func updateTrending(trendingModel: [Items]) {
        DispatchQueue.main.async {
            self.searchTableView.separatorStyle = .singleLine
            MBProgressHUD.hide(for: self.view, animated: true)
            self.searchTableView.reloadData()
        }
    }
    
}
