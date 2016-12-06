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
    
}

class StoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
//    var ref: FIRDatabaseReference!
    let ref = FIRDatabase.database().reference()
    var refHandle: UInt!
    var tourArray: NSMutableArray = []
    var nextArray: NSMutableArray = []

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let registeredUserRef = ref.child("tours")

        //Use this to get back all values from china
//        registeredUserRef.queryOrdered(byChild: "country").queryEqual(toValue: "China").observe(.value, with: { firDataSnapshot in
        
        registeredUserRef.queryOrdered(byChild: "country").observe(.value, with: { firDataSnapshot in
            let dictionary = firDataSnapshot.value as! NSDictionary
            let test = ((((dictionary.allValues as AnyObject?) ?? NSDictionary()) as AnyObject).value(forKey: "title"))
            
            self.tourArray.add(((((dictionary.allValues as AnyObject?) ?? NSDictionary()) as AnyObject).value(forKey: "title")) ?? String())
            self.nextArray = [self.tourArray.lastObject!]
            print(self.nextArray[0])
            self.tableView.reloadData()
        })

        

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath)as! TourTableViewCell
        
        print(self.nextArray)
        if self.nextArray {
            <#code#>
        }
        cell.titleLabel.text = "\(indexPath.row)"
        
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
