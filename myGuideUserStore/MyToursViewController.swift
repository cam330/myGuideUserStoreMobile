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
    var tourId:String!
}

class MyToursViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var numberOfTours: Int = 0
    var savedTourId: String!
    var objToPass: NSManagedObject!
    @IBOutlet var tableView: UITableView!
    var tourId: String!
    var tourToPass: Any!
    var toursArray: NSArray!
//    var tourObject: Any!
    

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
            
            print(searchResults)
            self.toursArray = searchResults as NSArray!;
//            print(self.toursArray[1])
//            self.tourObject = searchResults;
//            print(self.tourObject.)
            
            for tour in searchResults as [NSManagedObject] {
                print("\(tour.value(forKey: "tourId") as! String)")
                savedTourId = tour.value(forKey: "tourId") as! String
                self.objToPass = tour
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
    
            print("THIS", toursArray[indexPath.row])
            
            cell.titleLabel.text = (toursArray[indexPath.row] as AnyObject).value(forKey: "tourTitle") as? String
            cell.locationLabel.text = "\((toursArray[indexPath.row] as AnyObject).value(forKey: "tourAttraction") as! String), \((toursArray[indexPath.row] as AnyObject).value(forKey: "tourCountry") as! String)"
            cell.tourId = self.objToPass.value(forKey: "tourId") as! String?
            return cell
        }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)as! MyTourCell
        
        self.tourToPass = toursArray.object(at: indexPath.row);
        
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
//                tableView.deleteRows(at:[indexPath], with: UITableViewRowAnimation.fade)
                
            } catch {
                
            }

        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTourSegue" {
            
            let tourPage = segue.destination as? TourViewController
            
            tourPage?.theTour = self.tourToPass
            
            
        }
    }
 

}
