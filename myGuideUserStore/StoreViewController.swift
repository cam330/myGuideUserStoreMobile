//
//  StoreViewController.swift
//  myGuideUserStore
//
//  Created by Cameron Wilcox on 12/6/16.
//  Copyright © 2016 Cameron Wilcox. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class TourTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var tourKeyWordsLabel: UILabel!
    @IBOutlet var tourGuideNameLabel: UILabel!
    var tourId: NSString!
}

class StoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
//    var ref: FIRDatabaseReference!
    let ref = FIRDatabase.database().reference()
    var refHandle: UInt!
    var tourArray: NSMutableArray = []
    var nextArray: NSArray = []
    var passingDict = [NSDictionary]()
    var tourId: NSString!

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let registeredUserRef = ref.child("tours")

        //Use this to get back all values from china
//        registeredUserRef.queryOrdered(byChild: "country").queryEqual(toValue: "China").observe(.value, with: { firDataSnapshot in
        
//        registeredUserRef.queryOrdered(byChild: "country").observe(.value, with: { firDataSnapshot in
//            let dictionary = firDataSnapshot.value as! NSDictionary
//            let titles = ((((dictionary.allValues as AnyObject?) ?? NSDictionary()) as AnyObject).value(forKey: "title"))
//            let attractions = ((((dictionary.allValues as AnyObject?) ?? NSDictionary()) as AnyObject).value(forKey: "attraction"))
//            
////            print(attractions)
////            print(titles)
//            
//            self.newDict["titles"] = (titles as AnyObject?)!
//            self.newDict["attractions"] = attractions as! NSArray?
//            
//            print(self.newDict)
//
//            self.nextArray = (attractions as! NSArray?)!
//            
////            print(self.nextArray)
//            
//            self.nextArray = (titles as! NSArray?)!
////            print(self.nextArray)
//            
//            self.tableView.reloadData()
//            
//        })
        
        registeredUserRef.observe(.value, with: { snapshot in
            
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let dict = child.value as! NSDictionary
                let newDict: NSMutableDictionary = NSMutableDictionary()
//                print(child.key)
                newDict.setValue(child.key, forKey: "tourId")
                newDict.setValue(dict.value(forKey: "country") ?? NSString(), forKey: "country")
                newDict.setValue(dict.value(forKey: "attraction") ?? NSString(), forKey: "attraction")
                newDict.setValue(dict.value(forKey: "title") ?? NSString(), forKey: "title")
                newDict.setValue(dict.value(forKey: "keyWords") ?? NSString(), forKey: "keys")
                newDict.setValue(dict.value(forKey: "downloads" ?? String()), forKey: "downloads")

                self.passingDict.append(newDict)
            }
            
            print(self.passingDict.count)
            print(self.passingDict)
            self.tableView.reloadData()
            
        })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.passingDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath)as! TourTableViewCell
        
        
        if self.passingDict.count > 0 {
            cell.tourId = self.passingDict[indexPath.row].value(forKey: "tourId") as! NSString
            cell.titleLabel.text = "\(self.passingDict[indexPath.row].value(forKey: "title") as! NSString)"
            cell.tourGuideNameLabel.text = "\(self.passingDict[indexPath.row].value(forKey: "attraction") as! NSString),\(self.passingDict[indexPath.row].value(forKey: "country") as! NSString)"
            let stringToPresent = (self.passingDict[indexPath.row].value(forKey: "keys") as! NSArray).componentsJoined(by: ", ")
            print(stringToPresent)
            cell.tourKeyWordsLabel.text = "\(stringToPresent)"
            print(cell.tourId)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)as! TourTableViewCell
        
        print(cell.tourId)
        
        self.tourId = cell.tourId
        
        [self.performSegue(withIdentifier: "showTourDetails", sender: self)]
    }

    @IBAction func sortResults(sender: UIButton) {
//        
//        let dict = 
//        print(dict)
//        
//        let sorted = sorted(self.passingDict as Dictionary, {$0 < $1})
//        print(sorted)
        print(self.passingDict[0].value(forKey: "title")!)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTourDetails" {
            let nextScene = segue.destination as? TourDetailViewController
            
            nextScene?.tourId = self.tourId
            

        }
    }
 

}
