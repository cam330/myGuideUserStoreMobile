//
//  TourViewController.swift
//  myGuideUserStore
//
//  Created by Cameron Wilcox on 12/7/16.
//  Copyright © 2016 Cameron Wilcox. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import FirebaseAuth

class TourViewController: UIViewController, UINavigationBarDelegate {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet var tourMap: UIImageView!
    var theTour: Any!
    var tourAudio: NSArray!
    
    var audioPlayer: AVAudioPlayer?
    var audioData: NSData!
    var audioDataArray: NSMutableArray!
    
    var audioDataString:String = ""
    
    var blurEffectView:UIVisualEffectView = UIVisualEffectView()
    
    let dataArray:NSMutableArray = []
    
    var reviewView:ReviewView = ReviewView()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.ref = FIRDatabase.database().reference()
        
//        print("DATOUR",theTour)
        
        self.reviewView.cancelButton.addTarget(self, action: #selector(submitReview), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "End", style: .plain, target: self, action: #selector(endTourButton))
        
        let valueDict = (theTour as AnyObject).value(forKey: "tourPoints")
        let tourAudioArray: NSArray? = NSKeyedUnarchiver.unarchiveObject(with: valueDict as! Data) as? NSArray
        
        self.tourAudio = NSKeyedUnarchiver.unarchiveObject(with: valueDict as! Data) as? NSArray
        
        print(tourAudioArray?.count ?? Int())
        let count = tourAudioArray?.count ?? Int()
//        print(tourAudioArray! as NSArray)
        
        print(self.tourMap.frame.size)
        self.tourMap.isUserInteractionEnabled = true
        for i in 0 ..< count {
            let tourSizes = tourAudioArray?.object(at: i)
            let percentFromTop = (tourSizes as AnyObject).value(forKey: "percentTop") ?? String()
            let percentFromLeft = (tourSizes as AnyObject).value(forKey: "percentLeft") ?? String()
        
            let topPercentDecimal = percentFromTop as! Double / 100
            let leftPercentDecimal = percentFromLeft as! Double / 100
        
            let pointPlacementTop = topPercentDecimal * Double(self.tourMap.frame.size.height)
            let pointPlacementLeft = leftPercentDecimal * Double(self.tourMap.frame.size.width)
        
        
            print(pointPlacementTop, pointPlacementLeft)
        
            let pointButton = UIButton()
            pointButton.setTitle("\(i)", for: .normal)
            pointButton.setTitleColor(UIColor.blue, for: .normal)
            pointButton.backgroundColor = UIColor.green
            pointButton.frame = CGRect(x:pointPlacementTop - 5, y:pointPlacementLeft - 5, width:20, height:20)
            pointButton.addTarget(self, action: #selector(pointSelect(sender:)), for: .touchUpInside)
            self.tourMap.addSubview(pointButton)
            self.tourMap.bringSubview(toFront: pointButton)

        }
        
//        let dataArray:NSMutableArray = []
        
        for i in 0 ..< count {
            let passingData = (self.tourAudio.object(at: i) as AnyObject).value(forKey: "audio") as! String

//            print(passingData)
            let nsd:NSData = NSData(base64Encoded: passingData, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
//            print(nsd)
            
            
            
            self.audioDataString = String(format: "%@", passingData as! CVarArg)
            
            self.audioData = NSData(base64Encoded: self.audioDataString, options: [])
            
            print(self.audioData)
            print("DONE HERE")
            
            self.dataArray.insert(self.audioData, at: 0)
            
//            print(dataArray)
            
//            print("THAT", self.audioData ?? String())
        }
        
        print(self.dataArray)

    }
    
    @IBAction func endTourButton(sender: UIButton){
        
//        let newView = ReviewView(frame: CGRect(x: 0, y: 0, width: 250, height: 100))
////        myView.backgroundColor = UIColor.blue
////        let title =
//        self.view.addSubview(newView)
//        self.tourMap.bringSubview(toFront: newView)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        self.blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.blurEffectView.frame = view.bounds

        self.reviewView = ReviewView(frame: CGRect(x: self.tourMap.center.x - 125, y: self.tourMap.center.y - 175, width: 250, height: 300))
        self.reviewView.submitButton.addTarget(self, action: #selector(submitReview(sender:)), for: .touchUpInside)
        self.reviewView.cancelButton.addTarget(self, action: #selector(cancelReview(sender:)), for: .touchUpInside)
        self.tourMap.addSubview(blurEffectView)
        self.tourMap.addSubview(self.reviewView)
        self.tourMap.bringSubview(toFront: self.reviewView)
        
//        reviewView.delegate = self
    }
    
    @IBAction func submitReview(sender: UIButton!) {
        
        let user = FIRAuth.auth()?.currentUser
        
        let tourId = (theTour as AnyObject).value(forKey: "tourId")
        
        let commentText = self.reviewView.commentsTextView.text ?? String()
        let rating = self.reviewView.starRatingView.rating
        let userId = user?.uid ?? String()
        let reviewDate = NSDate().timeIntervalSince1970 * 1000

        print(commentText, rating, userId, reviewDate)
        
        self.ref.child("tours").child(tourId as! String).child("reviews").child(userId).setValue(["rating": rating, "comment": commentText, "datePosted": reviewDate])
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelReview(sender: UIButton!) {
        self.reviewView.removeFromSuperview()
        self.blurEffectView.removeFromSuperview()
    }
    
    @IBAction func pointSelect(sender: UIButton!){
        let buttonInt = Int((sender.titleLabel?.text)!)
        print(buttonInt ?? Int())
//        print((self.tourAudio.object(at: buttonInt!) as AnyObject).value(forKey: "audio") ?? String())
//        let passingData:Any = (self.tourAudio.object(at: buttonInt!) as AnyObject).value(forKey: "audio") ?? String()
//        self.audioDataString = String(format: "%@", passingData as! CVarArg)
//        self.audioData = NSData(base64Encoded: self.audioDataString, options: [])!
        print(self.dataArray.object(at: buttonInt!))
        self.audioData = self.dataArray.object(at: buttonInt!) as! NSData
        
        
        
//        print(self.audioDataArray)
        
        self.audioPlayer = try! AVAudioPlayer(data: self.audioData as Data, fileTypeHint: AVFileTypeWAVE)
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
