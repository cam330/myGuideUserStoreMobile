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
import AVFoundation


class tourReviewCell: UITableViewCell {
    
}

class TitleCell: UITableViewCell {
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var companyLabel: UILabel!
}

class TourStatsCell: UITableViewCell {
    
    @IBOutlet var durationLabel: UILabel!
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
}

class ReviewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var datePostedLabel: UILabel!
    @IBOutlet var starView: CosmosView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var reviewText: UITextView!
}

class TourDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    
    
//    @IBOutlet var audioView: UIView!
//    @IBOutlet var remainingTimeLabel: UILabel!
//    @IBOutlet var audioSlider: UISlider!
//    @IBOutlet var playPauseButton: UIButton!
    
    var audioPlayer: AVAudioPlayer?
//    var audioData: NSData!
//    var audioDataString:String = ""
    
    @IBOutlet var tourImageView: UIImageView!
    let ref = FIRDatabase.database().reference()
    var tourId: NSString!
    
    var indicator = UIActivityIndicatorView()
    var loadingView = UIView()

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
    
    var reviewsDict: NSMutableDictionary!
    
    var allReviewValues: NSArray!
    
    var numberOfDownloads: Int!
    
    var guideName = String()
    
    var tourDuration = String()
    
    var tourKeys = String()
    
    
    @IBOutlet var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator()
        self.indicator.startAnimating()
        
        self.title = "Tour"
        
        navigationController?.navigationBar.tintColor = .white
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)

        print("HERES THE NAME", self.tourId)
//        self.tourId = "btChJXUrUhbbJYpJuEPoZ17lfv731481298858803"
//        self.tourId = "btChJXUrUhbbJYpJuEPoZ17lfv731481765932801"
        
//        let bgImgView = UIImageView(image: UIImage(named: "chichenitza"))
//        bgImgView.frame = self.tableView.frame
//        self.tableView.backgroundView = bgImgView

//        tableView.backgroundView = UIImageView(image: UIImage(named: "chichenitza"))
        
//        let backgroundImage = UIImageView(frame: CGRect(x:0, y:0, width: self.tableView.frame.width, height: 200))
//        backgroundImage.clipsToBounds = true
//        backgroundImage.image = UIImage(named: "chichenitza");
        
        self.numberOfDownloads = 0
        
        let registeredUserRef = ref.child("tours").child(self.tourId as String)
        let reviewRef = ref.child("reviews").child(self.tourId as String)
        
            registeredUserRef.observe(.value, with: { snapshot in
                
                
                self.namesArray = snapshot.value as! NSDictionary!
                print("YESS",self.namesArray)
                
                self.tourImageView.image = UIImage(named: self.namesArray.value(forKey: "attraction")as! String)
//                
//                
//                
////                let passingData = ((points as AnyObject).object(at: i) as AnyObject).value(forKey: "sampleAudio") as! String
//                
//                if (self.namesArray.object(forKey: "sampleAudio") != nil) {
//                   
//                    let passingData = (self.namesArray.value(forKey: "sampleAudio")as! String)
//                    
//                    //            print(passingData)
////                    let nsd:NSData = NSData(base64Encoded: passingData, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
//                    //            print(nsd)
//                    
//                    
//                    
//                    
//                    
//                    
//
//                }
                
                self.ref.child("users").child(self.namesArray.value(forKey: "guide")as! String).observe(.value, with: { nameSnap in
                    print("DANAME",(nameSnap.value as! NSDictionary).value(forKey: "name")!)
                    self.guideName = "\((nameSnap.value as! NSDictionary).value(forKey: "name")!)"
                    
                    self.tableView.reloadData()
                    self.indicator.stopAnimating()
                })
                
                self.tourArray.insert(self.namesArray, at: 0)
                
                
            })
        
        
        ref.child("audioSamples").child(self.tourId as String).observe(.value, with:  {sampleAudio in
            print(sampleAudio.value!)
            
            if sampleAudio.exists() {
            
            
            let audioSamp = sampleAudio.value as! String
            

            
            self.audioDataString = String(format: "%@", audioSamp as CVarArg)
            
            self.audioData = NSData(base64Encoded: self.audioDataString, options: [])
            
            print(self.audioData)
            print("DONE HERE", audioSamp)
            
            
            self.audioPlayer = try! AVAudioPlayer(data: self.audioData as Data, fileTypeHint: AVFileTypeWAVE)
                
                self.indicator.stopAnimating()
                self.loadingView.removeFromSuperview()
            }
            
        })
        
        ref.child("tours").child(self.tourId as String).child("downloads").observe(.value, with: {snap in
            let snapValue = snap.value
            self.downloadCount = (snapValue as AnyObject).integerValue
            print(self.downloadCount!)
            
        })
        
        if self.numberOfDownloads > 0 {
        reviewRef.observe(.value, with: { snap in
            let toursArray = snap.value!
            
            self.reviewsDict = snap.value as! NSMutableDictionary
            
            self.allReviewValues = self.reviewsDict.allValues as NSArray
            
            print(self.allReviewValues[0])
        })
        } else {
            print("GOING HERE")
        }
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
                            tour.setValue(self.tourDuration, forKey: "tourDuration")
                            tour.setValue(date, forKey: "expireDate")
                            tour.setValue(self.tourKeys, forKey: "tourKeyWords")
                            
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
//        indicator.stopAnimating()
        
        
    }
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:0, height:0))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        indicator.center = self.view.center
        self.loadingView = UIView(frame: CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height))
        self.loadingView.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)
//        let view = UIView(frame: CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height))
//        view.backgroundColor = UIColor.blue
//        view.backgroundColor
//        self.view.addSubview(view)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        self.loadingView = UIVisualEffectView(effect: blurEffect)
        self.loadingView.frame = view.bounds
//        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(self.loadingView)
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
            return 120
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
                titleCell.locationLabel.text = "\(self.namesArray!.value(forKey: "attraction")!), \(self.namesArray!.value(forKey: "country")!)"
                titleCell.companyLabel.text = self.guideName
                return titleCell
            }
            if indexPath.row == 2 {
                statsCell.downloadsLabel.text = "\(self.namesArray!.value(forKey: "downloads")!)"
                let count = (self.namesArray!.value(forKey: "reviews") as AnyObject).value(forKey: "count")
                print(count!)
                let total = (self.namesArray!.value(forKey: "reviews") as AnyObject).value(forKey: "total")
                print(total!)
                if count as! Int > 0 {
                    let value = (total as! Int) / (count as! Int)
                    print(value)
                    statsCell.ratingView.rating = Double(value)
                } else {
                    statsCell.ratingView.rating = 5.0
                    self.numberOfDownloads = 0
                }
                
                statsCell.durationLabel.text = self.tourDuration
                
                statsCell.priceLabel.text = "$\(self.namesArray!.value(forKey: "price") as! String)"
                return statsCell
            }
            if indexPath.row == 3 {
                detailCell.detailTextView.text = self.namesArray!.value(forKey: "description") as! String?
                return detailCell
            }
            if indexPath.row == 4 {

                
                audioSampleCell.playButton.addTarget(self, action: #selector(playAudio(sender:)), for: .touchUpInside)
                return audioSampleCell
            }
            if indexPath.row == 5 {
                cell?.textLabel?.text = "Reviews"
                return cell!
            }
            if indexPath.row == 6 {
                reviewCell.starView.rating = 5.0
                reviewCell.nameLabel.text = "Charlie Johnson"
                reviewCell.reviewText.text = "This was a great tour! I learned so much and had a blast!"
                reviewCell.profileImage.image = UIImage(named: "Charlie")
                
                return reviewCell
            }
            if indexPath.row == 7 {
                reviewCell.starView.rating = 3.0
                reviewCell.nameLabel.text = "Sam Somebody"
                reviewCell.reviewText.text = "I enjoied this tour, Nothing amazing but a good a good price"
                reviewCell.profileImage.image = UIImage(named: "Sam")
                
                return reviewCell
            }
            if indexPath.row == 8 {
                reviewCell.starView.rating = 4.0
                reviewCell.nameLabel.text = "Greg Mitchel"
                reviewCell.reviewText.text = "I thought this tour wasn't long enough but I still liked it"
                reviewCell.profileImage.image = UIImage(named: "Greg")
                
                return reviewCell
            }
//            
//            
//            
//            
//            
//            
//            
//            if indexPath.row == 6|| indexPath.row == 7 || indexPath.row == 8 {
////                print(self.allReviewValues.object(at: indexPath.row - 6))
////                print((self.allReviewValues[indexPath.row - 6] as AnyObject).value(forKey: "rating") as! Double)
////                let rating = (self.allReviewValues[indexPath.row - 6] as AnyObject).value(forKey: "rating") as! Double
////                print("TATA", rating)
////                
//                if (self.namesArray.object(forKey: "rating") != nil) {
//                    let dateNumber = (self.allReviewValues[indexPath.row - 6] as AnyObject).value(forKey: "datePosted") as! NSNumber
//                    let myTimeInterval = TimeInterval(dateNumber.doubleValue)
//                    
//                    //                let date = NSDate(NSTimeIntervalSince1970: myTimeInterval)
//                    let newYears1971 = Date(timeIntervalSince1970: dateNumber.doubleValue as TimeInterval)
//                    print("date is \(newYears1971)")
//                    //
//                    //                print(date)
//                    //
//                    let formatter = DateFormatter()
//                    //                formatter.dateStyle = DateFormatter.Style.short
//                    let convertedDate = formatter.string(from: newYears1971 as Date)
//                    
//                    print(convertedDate)
//                    
//                    
//                    
//                    print(myTimeInterval)
//                    
//                    reviewCell.starView.rating = (self.allReviewValues[indexPath.row - 6] as AnyObject).value(forKey: "rating") as! Double
//                    reviewCell.nameLabel.text = (self.allReviewValues[indexPath.row - 6] as AnyObject).value(forKey: "user") as? String
//                    reviewCell.reviewText.text = (self.allReviewValues[indexPath.row - 6] as AnyObject).value(forKey: "comment") as! String
//                    //                reviewCell.datePostedLabel.text = postedDate
//                    //                reviewCell.nameLabel!.text = "JELLo"as! String
//
//                }
//                
//                
//                return reviewCell
//            }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let titleCell = tableView.dequeueReusableCell(withIdentifier: "tourTitleCell")as! TitleCell
        let statsCell = tableView.dequeueReusableCell(withIdentifier: "tourStatsCell")as! TourStatsCell
        let detailCell = tableView.dequeueReusableCell(withIdentifier: "tourDetailsCell")as! TourDetailsCell
        let audioSampleCell = tableView.dequeueReusableCell(withIdentifier: "audioSample")as! AudioSampleCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let reviewCell = tableView.dequeueReusableCell(withIdentifier: "reviewCell")as! ReviewCell
        
        titleCell.selectionStyle = UITableViewCellSelectionStyle.none
        statsCell.selectionStyle = UITableViewCellSelectionStyle.none
        detailCell.selectionStyle = UITableViewCellSelectionStyle.none
        audioSampleCell.selectionStyle = UITableViewCellSelectionStyle.none
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        reviewCell.selectionStyle = UITableViewCellSelectionStyle.none
    }
    

    @IBAction func playAudio(sender: UIButton!) {
        print("HELLLLO")
        self.audioPlayer?.delegate = self
        self.audioPlayer?.prepareToPlay()
        self.audioPlayer?.play()
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
