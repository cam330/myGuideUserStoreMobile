//
//  MyToursViewController.swift
//  myGuideUserStore
//
//  Created by Cameron Wilcox on 12/7/16.
//  Copyright © 2016 Cameron Wilcox. All rights reserved.
//

import UIKit
import CoreData

class MyTourCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var duration: UILabel!
    @IBOutlet var expireTimeLabel: UILabel!
    @IBOutlet var keyWordsLabel: UILabel!
}

class MyToursViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var numberOfTours: Int = 0
    var savedTourId: String!
    var objToPass: NSManagedObject!
    @IBOutlet var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let fetchRequest: NSFetchRequest<Tour> = Tour.fetchRequest()
        
        do {
            let searchResults = try getContext().fetch(fetchRequest)
            
            print("num of results = \(searchResults.count)")
            numberOfTours = searchResults.count
            
            for tour in searchResults as [NSManagedObject] {
                print("\(tour.value(forKey: "tourId") as! String)")
                savedTourId = tour.value(forKey: "tourId") as! String
//                print("\(tour.value(forKey: "tourPoints"))")
//                print("\(tour)")
                let valueDict = tour.value(forKey: "tourPoints")
                let dictionary: NSArray? = NSKeyedUnarchiver.unarchiveObject(with: valueDict as! Data) as? NSArray
//                print(dictionary ?? NSArray())
                self.objToPass = tour
                print(self.objToPass)
                self.tableView.reloadData()
            }
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Table view data source
    
         func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
        }
    
         func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            return numberOfTours
        }
    
    
         func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tourCell", for: indexPath)as! MyTourCell
    
    
            cell.titleLabel.text = self.objToPass.value(forKey: "tourTitle") as! String?
            cell.locationLabel.text = "\(self.objToPass.value(forKey: "tourAttraction") as! String), \(self.objToPass.value(forKey: "tourCountry") as! String)"
            return cell
        }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)as! MyTourCell
        
        [self.performSegue(withIdentifier: "showTourSegue", sender: self)]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let fetchRequest: NSFetchRequest<Tour> = Tour.fetchRequest()
            
            do {
                let cdResults = try getContext().fetch(fetchRequest)
                
                for tour in cdResults as [NSManagedObject] {
                    getContext().delete(tour)
                    print("Deleted!")
                    
                }
                
                try getContext().save()
                numberOfTours = 0
                savedTourId = nil
                tableView.deleteRows(at:[indexPath], with: UITableViewRowAnimation.fade)
                
            } catch {
                
            }

        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTourSegue" {
            
            var tourPage = segue.destination as? TourViewController
            
        }
    }
 

}
