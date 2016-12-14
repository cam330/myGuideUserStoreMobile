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
import Cosmos
import Stripe


class tourReviewCell: UITableViewCell {
    
}

class TitleCell: UITableViewCell {
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var companyLabel: UILabel!
}

class TourStatsCell: UITableViewCell {
    
    @IBOutlet var ratingView: CosmosView!
    @IBOutlet var downloadsLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
}

class TourDetailsCell: UITableViewCell {
    @IBOutlet var detailTextView: UITextView!
    @IBOutlet var detailLabel: UILabel!
}

class AudioSampleCell: UITableViewCell {
    @IBOutlet var playButton: UIButton!
    @IBOutlet var audioProgres: UIProgressView!
}

class ReviewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var datePostedLabel: UILabel!
    @IBOutlet var starView: CosmosView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var reviewTest: UITextView!
}

class TourDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let ref = FIRDatabase.database().reference()
    var tourId: NSString!
    
    var indicator = UIActivityIndicatorView()

    @IBOutlet var tableView: UITableView!

    var data: NSData!
    
    var namesArray: NSDictionary!
    
    var downloadCount: Int!
    
    var audioDataString:String = ""
    
    var audioData: NSData!
    
    var dataArray:NSMutableArray = []
    
    var audioDataData: NSData!
    
    let audioArray:NSMutableArray = []
    
    var tourArray: NSMutableArray = []
    
    
    @IBOutlet var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

//        print("HERES THE NAME", self.tourId)
        self.tourId = "btChJXUrUhbbJYpJuEPoZ17lfv731481125126181";
        
//        let bgImgView = UIImageView(image: UIImage(named: "chichenitza"))
//        bgImgView.frame = self.tableView.frame
//        self.tableView.backgroundView = bgImgView

//        tableView.backgroundView = UIImageView(image: UIImage(named: "chichenitza"))
        
//        let backgroundImage = UIImageView(frame: CGRect(x:0, y:0, width: self.tableView.frame.width, height: 200))
//        backgroundImage.clipsToBounds = true
//        backgroundImage.image = UIImage(named: "chichenitza");
        
        let registeredUserRef = ref.child("tours").child(self.tourId as String)
        
        
            registeredUserRef.observe(.value, with: { snapshot in
                
                
                self.namesArray = snapshot.value as! NSDictionary!
                print(self.namesArray)
                
                self.tourArray.insert(self.namesArray, at: 0)
                self.tableView.reloadData()
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
                        self.activityIndicator()
                        
                        self.indicator.startAnimating()
                        self.indicator.backgroundColor = UIColor.white
            
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
        indicator.stopAnimating()
        
        
    }
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:0, height:0))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        indicator.center = self.view.center
//        let view = UIView(frame: CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height))
//        view.backgroundColor = UIColor.blue
//        view.backgroundColor
//        self.view.addSubview(view)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
//        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(blurEffectView)
        self.view.addSubview(indicator)
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
        return 11
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0 {
            return 90
        } else if indexPath.row == 1 {
            return 100
        } else if indexPath.row == 2{
            return 70
        }else if indexPath.row == 3 {
            return 150
        } else if indexPath.row == 4 {
            return 70
        } else if indexPath.row == 5 || indexPath.row == 9{
            return 25
        } else if indexPath.row == 6 || indexPath.row == 7 || indexPath.row == 8 {
            return 92
        } else if indexPath.row == 10{
            return 60
        } else {
            return 0
        }
        
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let titleCell = tableView.dequeueReusableCell(withIdentifier: "tourTitleCell")as! TitleCell
        let statsCell = tableView.dequeueReusableCell(withIdentifier: "tourStatsCell")as! TourStatsCell
        let detailCell = tableView.dequeueReusableCell(withIdentifier: "tourDetailsCell")as! TourDetailsCell
        let audioSampleCell = tableView.dequeueReusableCell(withIdentifier: "audioSample")as! AudioSampleCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let reviewCell = tableView.dequeueReusableCell(withIdentifier: "reviewCell")as! ReviewCell


        if self.tourArray.count > 0 {
            
            if indexPath.row == 0 {
                cell?.backgroundColor = UIColor.clear
                cell?.textLabel?.text = ""
                return cell!
            }
            if indexPath.row == 1 {
                titleCell.titleLabel.text = self.namesArray!.value(forKey: "title") as! String?
                titleCell.locationLabel.text = "\(self.namesArray!.value(forKey: "attraction") as! String?), \(self.namesArray!.value(forKey: "country") as! String?)"
                titleCell.companyLabel.text = self.namesArray!.value(forKey: "guide") as! String?
                return titleCell
            }
            if indexPath.row == 2 {
                statsCell.downloadsLabel.text = self.namesArray!.value(forKey: "downloads") as! String?
                let count = (self.namesArray!.value(forKey: "reviews") as! Array)[0]
                let total = (self.namesArray!.value(forKey: "reviews") as! Array)[1]
//                let value = total!/count!
                print(total, count)
//                statsCell.ratingView.rating = Double(value)
                statsCell.priceLabel.text = self.namesArray!.value(forKey: "price") as! String?
                return statsCell
            }
            if indexPath.row == 3 {
                return detailCell
            }
            if indexPath.row == 4 {
                return audioSampleCell
            }
            if indexPath.row == 5 {
                cell?.textLabel?.text = "Reviews"
                return cell!
            }
            if indexPath.row == 6 || indexPath.row == 7 || indexPath.row == 8 {
                return reviewCell
            }
            if indexPath.row == 9 {
                cell?.textLabel?.text = "Contact us"
                return cell!
            }
            if indexPath.row == 10 {
                cell?.textLabel?.text = ""
                return cell!
            }
            

        }
            
        
        return cell!
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
