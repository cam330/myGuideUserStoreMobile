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
import CoreData

class TourDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let ref = FIRDatabase.database().reference()
    var tourId: NSString!

    @IBOutlet var tableView: UITableView!

    var data: NSData!
    
    var namesArray: NSDictionary!
    
    var downloadCount: Int!
    
    var audioDataString:String = ""
    
    var audioData: NSData!
    
    var dataArray:NSMutableArray = []
    
    var audioDataData: NSData!
    
    let audioArray:NSMutableArray = []
    
    @IBOutlet var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        print("HERES THE NAME", self.tourId)

        
        
        let registeredUserRef = ref.child("tours").child(self.tourId as String)
        
        
            registeredUserRef.observe(.value, with: { snapshot in
                
                
                self.namesArray = snapshot.value as! NSDictionary!
                print(self.namesArray)
                print(self.namesArray.value(forKey: "keyWords") ?? String())
            })

        ref.child("tours").child(self.tourId as String).child("downloads").observe(.value, with: {snap in
            let snapValue = snap.value
            self.downloadCount = (snapValue as AnyObject).integerValue
            print(self.downloadCount!)
            
        })
        
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func downloadTour(_ sender: Any) {
        
        let user = FIRAuth.auth()?.currentUser
        let email = user?.email
        
    
        let alert = UIAlertController(title: "Purchase Tour?", message: "Enter your password to purchase tour", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
            
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
//            print("Text field: \(textField?.text)")
            print(email! as String)
                FIRAuth.auth()?.signIn(withEmail: email! as String, password: (textField?.text!)!) { (user, error) in
                    if error == nil {
                        print("WORKS")
            
                        let context = self.getContext()
                        let entity = NSEntityDescription.entity(forEntityName: "Tour", in: context)
                        
                        let tour = NSManagedObject(entity: entity!, insertInto: context)
                        
                        let audioRef = self.ref.child("audio").child(self.tourId as String)
                        
                        
                        
                        let formatted = DateFormatter()
                        
                        formatted.dateStyle = .short
                        
                        let time = NSDate().timeIntervalSince1970 + 604800
                        
                        let date = NSDate(timeIntervalSince1970: time)
                        let formattedDate = formatted.string(from:date as Date)
                        
                        
                        
                        audioRef.observe(.value, with: { snapshot in
                            
                            let dict = snapshot.value as! NSDictionary
                            var points = dict.value(forKey: "points") ?? NSDictionary()
                            
                            //            print("POINTS TO WRAP", (points as AnyObject).count)
                            
                            
                            for i in 0 ..< (points as AnyObject).count {
                                let passingData = ((points as AnyObject).object(at: i) as AnyObject).value(forKey: "audio") as! String
                                
                                //            print(passingData)
                                let nsd:NSData = NSData(base64Encoded: passingData, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
                                //            print(nsd)
                                
                                
                                
                                self.audioDataString = String(format: "%@", passingData as CVarArg)
                                
                                self.audioData = NSData(base64Encoded: self.audioDataString, options: [])
                                
                                //                print(self.audioData)
                                print("DONE HERE")
                                
                                self.dataArray.insert(self.audioData, at: i)
                                
                                //            print(dataArray)
                                
                                //            print("THAT", self.audioData ?? String())
                                
                                //                self.audioArray.insert(self.audioData, at: i)
                                
                            }
                            
                            
                            
                            //            print("DATA", self.dataArray)
                            
                            
                            
                            self.data = NSKeyedArchiver.archivedData(withRootObject: points) as NSData
                            self.audioDataData = NSKeyedArchiver.archivedData(withRootObject: self.dataArray) as NSData
                            
                            print(self.audioDataData)
                            
                            tour.setValue(self.tourId, forKey: "tourId")
                            tour.setValue(self.namesArray.value(forKey: "attraction") ?? String(), forKey: "tourAttraction")
                            tour.setValue(self.namesArray.value(forKey: "country") ?? String(), forKey: "tourCountry")
                            tour.setValue(self.namesArray.value(forKey: "title") ?? String(), forKey: "tourTitle")
                            tour.setValue(self.data, forKey: "tourPoints")
                            tour.setValue(self.audioDataData, forKey: "tourPointsAudio")
                            tour.setValue(date, forKey: "expireDate")
                            
                            do{
                                try context.save()
                                print("Saved!")
                                
                                let viewControllers: [UIViewController] = self.navigationController!.viewControllers ;
                                for aViewController in viewControllers {
                                    if(aViewController is MyToursViewController){
                                        self.navigationController!.popToViewController(aViewController, animated: true);
                                    }
                                }
                            } catch let error as NSError {
                                print("Could not save \(error),\(error.userInfo)")
                            } catch {
                                
                            }
                            
                        })
                        self.downloadCount = self.downloadCount! + 1
                        print(self.downloadCount!)
                        self.ref.child("tours").child(self.tourId as String).child("downloads").setValue("\(self.downloadCount!)")

                        
                    } else {
                        print(error)
                    }
                }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }

    
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
//    func storeTour (tourId: String) {
//        
//    }
//
//    @IBAction func downloadTour(_ sender: Any) {
//        
//    }
    
    
//     MARK: - Table view data source 
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tourDetailCell", for: indexPath)
        
        
//        cell.textLabel?.text = String(format: "%d", indexPath.row+3)
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
