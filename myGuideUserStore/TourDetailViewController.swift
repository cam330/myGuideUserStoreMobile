//
//  TourDetailViewController.swift
//  myGuideUserStore
//
//  Created by Cameron Wilcox on 11/28/16.
//  Copyright © 2016 Cameron Wilcox. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class TourDetailViewController: UIViewController {
    
    
    let ref = FIRDatabase.database().reference()
    var tourId: NSString!
    @IBOutlet var tableView: UITableView!
    
    var getObjects = ["country", "attraction", "title", "price", "keyWords", "description"]
    var passingDict = [NSDictionary]()
    
    @IBOutlet var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        print("HERES THE NAME", self.tourId)
        // Do any additional setup after loading the view.
        
        let registeredUserRef = ref.child("tours").child(self.tourId as String)
        
        
        for i in 0 ..< self.getObjects.count {
            
            registeredUserRef.child(self.getObjects[i]).observe(.value, with: { snapshot in
                
//                print(snapshot.value ?? String())
                let obj = snapshot.value
                let newDict: NSMutableDictionary = NSMutableDictionary()
                
                newDict.setValue(obj, forKey: self.getObjects[i])
                
//                print(newDict)
                
                self.passingDict.append(newDict)
                
                print(self.passingDict)
                
                self.reloadInputViews()
            })
        }
        
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view data source
    
//     func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//    
//     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 4
//    }
    
    
//     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "tourDetailCells", for: indexPath)
//        
//        
//        cell.textLabel?.text = String(format: "%d", indexPath.row+3)
//        return cell
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
