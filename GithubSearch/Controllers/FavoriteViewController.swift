//
//  FavoriteViewController.swift
//  GithubSearch
//
//  Created by Tarokh on 8/10/20.
//  Copyright © 2020 Tarokh. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import CoreData

class FavoriteViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet var favoriteTableView: UITableView!
    
    
    
    //MARK: - Variables
    var favoriteItems: [NSManagedObject] = []
    var managedContext: NSManagedObjectContext?
    
    
    //MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()

        favoriteTableView.register(UINib(nibName: "FavoriteCell", bundle: nil), forCellReuseIdentifier: "favoriteCell")
        
        favoriteTableView.separatorStyle = .none
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
        favoriteTableView.emptyDataSetSource = self
        favoriteTableView.emptyDataSetDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        favoriteItems = []
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Github")
        do {
            let favorites = try managedContext!.fetch(fetchRequest)
            for data in favorites {
                favoriteItems.append(data)
                DispatchQueue.main.async {
                    self.favoriteTableView.separatorStyle = .singleLine
                    self.favoriteTableView.reloadData()
                }
            }
            
        }catch let error as NSError {
            print("Could not fetch the data: \(error.localizedDescription)")
        }
    }
    
    //MARK: - Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToURL" {
            let webVC = segue.destination as? WebController
            let indexPath = self.favoriteTableView.indexPathForSelectedRow
            let item = favoriteItems[indexPath!.row]
            let urlItem = item.value(forKey: "htmlURL") as! String
            webVC?.url = urlItem
        }
    }
    

}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell") as! FavoriteCell
        let item = favoriteItems[indexPath.row]
        cell.nameLabel.text = item.value(forKey: "fullName") as? String
        cell.descriptionLabel.text = item.value(forKey: "desc") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToURL", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            context.delete(favoriteItems[indexPath.row] as NSManagedObject)
            favoriteItems.remove(at: indexPath.row)
            do {
                try context.save()
                self.favoriteTableView.deleteRows(at: [indexPath], with: .fade)
            }catch let error as NSError {
                print("Could not delete the selected item: \(error.localizedDescription)")
            }
        }
    }
    
}

//MARK: - DZNEmptyDataSetDelegate, DZNEmptyDataSetSource
extension FavoriteViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Bookmark some github repositories!"

        let attributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0),
            NSAttributedString.Key.foregroundColor: UIColor.darkGray
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }
    
}
