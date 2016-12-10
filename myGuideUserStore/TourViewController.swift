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

class TourViewController: UIViewController, UINavigationBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet var audioSlider: UISlider!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var tourMap: UIImageView!
    var theTour: Any!
    var tourAudio: NSArray!
    
    var audioPlayer: AVAudioPlayer?
    var audioData: NSData!
    var audioDataArray: NSMutableArray!
    
    var audioDataString:String = ""
    
    var blurEffectView:UIVisualEffectView = UIVisualEffectView()
    
    let dataArray:NSMutableArray = []
    
    var buttonInt: Int!
    
    var reviewView:ReviewView = ReviewView()
    
    @IBOutlet var playingLabel: UILabel!
    
    var audioProgress: Float!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.ref = FIRDatabase.database().reference()
        
        
        print("DATOUR",theTour)
        
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
            let percentFromLeft = (tourSizes as AnyObject).value(forKey: "percentTop") ?? String()
            let percentFromTop = (tourSizes as AnyObject).value(forKey: "percentLeft") ?? String()
            
            print("PERC", percentFromLeft, percentFromTop)
        
            let topPercentDecimal = percentFromTop as! Double / 100
            let leftPercentDecimal = percentFromLeft as! Double / 100
        
            let pointPlacementTop = topPercentDecimal * Double(self.tourMap.frame.size.width)
            let pointPlacementLeft = leftPercentDecimal * Double(self.tourMap.frame.size.height)
        
        
            print(pointPlacementTop, pointPlacementLeft)
        
            let pointButton = UIButton()
            pointButton.setTitle("\(i+1)", for: .normal)
            pointButton.setTitleColor(UIColor.blue, for: .normal)
            pointButton.backgroundColor = UIColor.green
            pointButton.frame = CGRect(x:pointPlacementTop-5, y:pointPlacementLeft-20, width:20, height:20)
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
    
//    @IBAction func playAudio(sender: AnyObject) {
//
//    }
//    
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
        self.audioProgress = 0.0
        self.buttonInt = Int((sender.titleLabel?.text)!)!-1
        print(self.buttonInt ?? Int())
        self.playPauseButton.setTitle("Play", for: .normal)
        
        let titleLabel = (tourAudio.object(at: buttonInt+1) as AnyObject).value(forKey: "title")
        self.playingLabel.text = "\(self.buttonInt!). \(titleLabel as! String)"
        
        //        print((self.tourAudio.object(at: buttonInt!) as AnyObject).value(forKey: "audio") ?? String())
//        let passingData:Any = (self.tourAudio.object(at: buttonInt!) as AnyObject).value(forKey: "audio") ?? String()
//        self.audioDataString = String(format: "%@", passingData as! CVarArg)
//        self.audioData = NSData(base64Encoded: self.audioDataString, options: [])!
        
//        self.playingLabel.text = "\(self.buttonInt). \(theTour.)"
        
//        print(self.audioDataArray)
        

    }
    
    func updateTime(_ timer: Timer) {
        self.audioSlider.value = Float((self.audioPlayer?.currentTime)!)
    }
    
    @IBAction func sliderValueChange(sender: UISlider){
        print(self.audioSlider.value)
        self.audioProgress = self.audioSlider.value
        self.audioPlayer?.currentTime = TimeInterval(self.audioProgress)
    }
    
    @IBAction func playAudio(sender: UIButton!) {

        if sender.titleLabel?.text == "Play" {
        self.playPauseButton.setTitle("Pause", for: .normal)
        print(self.dataArray.object(at: self.buttonInt!))
        self.audioData = self.dataArray.object(at: self.buttonInt!) as! NSData
        self.audioPlayer = try! AVAudioPlayer(data: self.audioData as Data, fileTypeHint: AVFileTypeWAVE)
        self.audioPlayer?.prepareToPlay()
        self.audioPlayer?.currentTime = TimeInterval(self.audioProgress)
        self.audioSlider.maximumValue = Float((self.audioPlayer?.duration)!)
        self.audioSlider.value = 0.0
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        
        self.audioPlayer?.play()
        print("DURAT",audioPlayer?.duration ?? String())
        print("CURTM",audioPlayer?.currentTime ?? String())
        } else {
            self.playPauseButton.setTitle("Play", for: .normal)
            self.audioPlayer?.pause()
            
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.audioPlayer?.currentTime = 0
        self.playPauseButton.setTitle("Play", for: .normal)
    }
    
    // CAMERA
    
    @IBAction func openCameraButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if(picker.sourceType == UIImagePickerControllerSourceType.camera)
        {
            // Access the uncropped image from info dictionary
//            var imageToSave: UIImage = info.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
            let imageToSave1: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage //same but with different way
            
            UIImageWriteToSavedPhotosAlbum(imageToSave1, nil, nil, nil)
            self.dismiss(animated: true, completion: nil)
            
        }
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
