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

class TourViewController: UIViewController, UINavigationBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate{
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet var audioView: UIView!
    @IBOutlet var remainingTimeLabel: UILabel!
    @IBOutlet var audioSlider: UISlider!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var tourMap: UIImageView!
    var theTour: Any!
    var tourPoints: NSArray!
    var tourAudio: NSArray!
    
    var audioPlayer: AVAudioPlayer?
    var audioData: NSData!
    var audioDataArray: NSMutableArray!
    
    var audioDataString:String = ""
    
    var blurEffectView:UIVisualEffectView = UIVisualEffectView()
    
    var dataArray:NSMutableArray = []
    
    var buttonInt: Int!
    
    var reviewView:ReviewView = ReviewView()
    
    var pointDetails:pointDetailView = pointDetailView()
    
    var total = Int()
    var count = Int()
    var tourId = String()
    
    
    @IBOutlet var playingLabel: UILabel!
    
    var audioProgress: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.audioSlider.setThumbImage(self.generateHandleImage(with: .white), for: .normal)
        
        self.audioView.isHidden = true
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        
        self.ref = FIRDatabase.database().reference()
        
        
//        print("DATOUR",theTour)
        
        print("TIDTIE",self.tourId)
        
        self.reviewView.cancelButton.addTarget(self, action: #selector(submitReview), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "End", style: .plain, target: self, action: #selector(endTourButton))
        
        let valueDict = (theTour as AnyObject).value(forKey: "tourPoints")
        let tourAudioArray: NSArray? = NSKeyedUnarchiver.unarchiveObject(with: valueDict as! Data) as? NSArray
        
        self.tourPoints = NSKeyedUnarchiver.unarchiveObject(with: valueDict as! Data) as? NSArray
        
        let audios = (theTour as AnyObject).value(forKey: "tourPointsAudio")
        self.dataArray = (NSKeyedUnarchiver.unarchiveObject(with: audios as! Data) as? NSMutableArray)!
        
        
        
//        print(tourAudioArray?.count ?? Int())
        let count = tourAudioArray?.count ?? Int()
//        print(tourAudioArray! as NSArray)
        
//        print(self.tourMap.frame.size)
        self.tourMap.isUserInteractionEnabled = true
        for i in 0 ..< count {
            let tourSizes = tourAudioArray?.object(at: i)
            let percentFromLeft = (tourSizes as AnyObject).value(forKey: "percentTop") ?? String()
            let percentFromTop = (tourSizes as AnyObject).value(forKey: "percentLeft") ?? String()
            
//            print("PERC", percentFromLeft, percentFromTop)
        
            let topPercentDecimal = percentFromTop as! Double / 100
            let leftPercentDecimal = percentFromLeft as! Double / 100
        
            let pointPlacementTop = topPercentDecimal * Double(self.tourMap.frame.size.width)
            let pointPlacementLeft = leftPercentDecimal * Double(self.tourMap.frame.size.height)
        
        
//            print(pointPlacementTop, pointPlacementLeft)
        
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
        
//        for i in 0 ..< count {
//            let passingData = (self.tourAudio.object(at: i) as AnyObject).value(forKey: "audio") as! String
//
////            print(passingData)
//            let nsd:NSData = NSData(base64Encoded: passingData, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
////            print(nsd)
//            
//            
//            
//            self.audioDataString = String(format: "%@", passingData as! CVarArg)
//            
//            self.audioData = NSData(base64Encoded: self.audioDataString, options: [])
//            
//            print(self.audioData)
//            print("DONE HERE")
//            
//            self.dataArray.insert(self.audioData, at: 0)
//            
////            print(dataArray)
//            
////            print("THAT", self.audioData ?? String())
//        }
//        
//        print(self.dataArray)

    }
    


    @IBAction func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.up:

                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                    imagePicker.allowsEditing = false
                    self.present(imagePicker, animated: true, completion: nil)
                }
                
            default:
                break
            }
        }
    }

    private func generateHandleImage(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        return UIGraphicsImageRenderer(size: rect.size).image { (imageContext) in
            imageContext.cgContext.setFillColor(UIColor.lightGray.cgColor)
            imageContext.cgContext.fill(rect.insetBy(dx: 10, dy: 10))
        }
    }

    
    @IBAction func endTourButton(sender: UIButton){
        self.audioView.isHidden = true
        navigationController?.navigationBar.isUserInteractionEnabled=false
        navigationController?.navigationBar.tintColor = UIColor.lightGray
        
        
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
        
        self.ref.child("tours").child(tourId as! String).child("reviews").observe(.value, with: { snapshot in
            print("SNVAL", snapshot.value)
            
            self.total = (snapshot.value as AnyObject).value(forKey: "total") as! Int
            self.count = (snapshot.value as AnyObject).value(forKey: "count") as! Int
            
            print("Total\(self.total) COUNT\(self.count)")
            
            
            
        })
        
//        reviewView.delegate = self
    }
    
    @IBAction func submitReview(sender: UIButton!) {
        navigationController?.navigationBar.isUserInteractionEnabled=true
        navigationController?.navigationBar.tintColor = self.view.tintColor
        
        let user = FIRAuth.auth()?.currentUser
        
        let tourId = (theTour as AnyObject).value(forKey: "tourId")
        
        let commentText = self.reviewView.commentsTextView.text ?? String()
        let rating = self.reviewView.starRatingView.rating
        let userId = user?.uid ?? String()
        let reviewDate = NSDate().timeIntervalSince1970 * 1000

//        print(commentText, rating, userId, reviewDate)
        let reviewId = "\(userId)\(Int(reviewDate))"
        print(reviewId)
        
        self.ref.child("reviews").child(tourId as! String).child(reviewId).setValue(["user": userId, "rating": rating, "comment": commentText, "datePosted": reviewDate])
        
        self.ref.child("tours").child(tourId as! String).child("reviews").setValue(["total": Int(rating)+self.total, "count": 1+self.count])
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelReview(sender: UIButton!) {
        self.reviewView.removeFromSuperview()
        self.blurEffectView.removeFromSuperview()
        self.audioView.isHidden = false
        navigationController?.navigationBar.isUserInteractionEnabled=true
        navigationController?.navigationBar.tintColor = self.view.tintColor
    }
    
    @IBAction func pointSelect(sender: UIButton!){
        
        self.audioView.isHidden = false
        
        for subview in self.tourMap.subviews{
            subview.backgroundColor = UIColor.green
            sender.backgroundColor = UIColor.red
        }
        
        

        
        if self.buttonInt == Int((sender.titleLabel?.text)!) {
            
            if self.pointDetails.isDescendant(of: self.tourMap) {
                
                self.pointDetails.removeFromSuperview()
            } else {
                
                self.pointDetails = pointDetailView(frame: CGRect(x: sender.center.x - 20, y: sender.center.y + 20, width: 175, height: 60))
                self.pointDetails.detailText.text = (tourPoints.object(at: buttonInt-1) as AnyObject).value(forKey: "detail") as! String
                self.tourMap.addSubview(self.pointDetails)
                self.tourMap.bringSubview(toFront: self.pointDetails)
            }
        
        } else {

            self.pointDetails.removeFromSuperview()
            self.audioProgress = 0.0
            self.buttonInt = Int((sender.titleLabel?.text)!)!
            self.playPauseButton.setTitle("Play", for: .normal)
            
            let titleLabel = (tourPoints.object(at: buttonInt-1) as AnyObject).value(forKey: "title")
            self.playingLabel.text = "\(self.buttonInt!). \(titleLabel as! String)"
            
            self.audioData = self.dataArray.object(at: self.buttonInt!-1) as! NSData
            self.audioPlayer = try! AVAudioPlayer(data: self.audioData as Data, fileTypeHint: AVFileTypeWAVE)
            
            self.remainingTimeLabel.text = stringFromTimeInterval(interval: (self.audioPlayer?.duration)!) as String
            print(self.remainingTimeLabel.text)
            
            self.pointDetails = pointDetailView(frame: CGRect(x: sender.center.x - 20, y: sender.center.y + 20, width: 175, height: 60))
            self.pointDetails.detailText.text = (tourPoints.object(at: buttonInt-1) as AnyObject).value(forKey: "detail") as! String
            self.tourMap.addSubview(self.pointDetails)
            self.tourMap.bringSubview(toFront: self.pointDetails)
        }
        
        
        //        print((self.tourAudio.object(at: buttonInt!) as AnyObject).value(forKey: "audio") ?? String())
//        let passingData:Any = (self.tourAudio.object(at: buttonInt!) as AnyObject).value(forKey: "audio") ?? String()
//        self.audioDataString = String(format: "%@", passingData as! CVarArg)
//        self.audioData = NSData(base64Encoded: self.audioDataString, options: [])!
        
//        self.playingLabel.text = "\(self.buttonInt). \(theTour.)"
        
//        print(self.audioDataArray)
        

    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> NSString {
        
        let ti = NSInteger(interval)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        
        return NSString(format: "%0.2d:%0.2d",minutes,seconds)
    }
    
    func updateTime(_ timer: Timer) {
        self.audioSlider.value = Float((self.audioPlayer?.currentTime)!)
        
        let currentTime = Double((self.audioPlayer?.currentTime)!)
        let duration = Double((self.audioPlayer?.duration)!)
        
        self.remainingTimeLabel.text = stringFromTimeInterval(interval:(TimeInterval(Int(duration) - Int(currentTime)))) as String
    }
    
    @IBAction func sliderValueChange(sender: UISlider){
//        print(self.audioSlider.value)
        self.audioProgress = self.audioSlider.value
        self.audioSlider.setValue(self.audioProgress, animated: true)
        self.audioPlayer?.currentTime = TimeInterval(self.audioProgress)
    }
    
    @IBAction func playAudio(sender: UIButton!) {

        if sender.titleLabel?.text == "Play" {
            let device = UIDevice.current
            device.isProximityMonitoringEnabled = true
        self.playPauseButton.setTitle("Pause", for: .normal)
//        print(self.dataArray.object(at: self.buttonInt!-1))
//        self.audioData = self.dataArray.object(at: self.buttonInt!-1) as! NSData
//        self.audioPlayer = try! AVAudioPlayer(data: self.audioData as Data, fileTypeHint: AVFileTypeWAVE)
        self.audioSlider.value = self.audioProgress
        self.audioPlayer?.delegate = self
        self.audioPlayer?.prepareToPlay()
        self.audioPlayer?.currentTime = TimeInterval(self.audioProgress)
        self.audioSlider.maximumValue = Float((self.audioPlayer?.duration)!)
        self.audioSlider.value = 0.0
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        
        self.audioPlayer?.play()
//        print("DURAT",audioPlayer?.duration ?? String())
//        print("CURTM",audioPlayer?.currentTime ?? String())
        } else {
            self.playPauseButton.setTitle("Play", for: .normal)
            self.audioProgress = Float((self.audioPlayer?.currentTime)!)
            self.audioPlayer?.pause()
            let device = UIDevice.current
            device.isProximityMonitoringEnabled = false
            
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("DONEEEEE")
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = false
        player.currentTime = 0
        self.playPauseButton.setTitle("Play", for: .normal)
        player.stop()
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
