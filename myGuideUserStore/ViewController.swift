//
//  ViewController.swift
//  myGuideUserStore
//
//  Created by Cameron Wilcox on 11/28/16.
//  Copyright © 2016 Cameron Wilcox. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {
    
//    let storage = FIRStorage.storage()
    let ref = FIRDatabase.database().reference()
    var tourArray: NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
    
    }

    @IBAction func getData(_ sender: Any) {
        
        let conditionRef = ref.child("tours").child("france")
        
        conditionRef.observe(FIRDataEventType.value, with: {(snapshot) in
//            let postDict = snapshot.value as? [String: AnyObject] ?? [:]
            var tempItems = [NSDictionary]()
//            print("TEST1",tempItems)
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
//                print("TEST2",child)

            }
            
            print("COMPLETE")
        })
        
        
        
        conditionRef.observe(.value, with: { snapshot in
//            print(snapshot.value ?? String())
            
            self.tourArray.add(snapshot.value ?? String())
            
//            let passingArray = (((self.tourArray.value(forKey: "array")) as AnyObject).value(forKey: "audio"))
            
            let passingArray = ((((snapshot.value as AnyObject).value(forKey: "array")) as AnyObject).value(forKey: "audio"))
            
            let partitionArray = (passingArray as! NSArray?)![1]
            
            var base64String : String!
            
            print(partitionArray)
            
//            print("TEST3",passingArray ?? String())
        })
    }
    
    @IBAction func showData(_ sender: Any) {
        print(self.tourArray)
    }

}

