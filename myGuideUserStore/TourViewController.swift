//
//  TourViewController.swift
//  myGuideUserStore
//
//  Created by Cameron Wilcox on 12/7/16.
//  Copyright © 2016 Cameron Wilcox. All rights reserved.
//

import UIKit
import AVFoundation

class TourViewController: UIViewController, UINavigationBarDelegate {
    
    @IBOutlet var tourMap: UIImageView!
    var theTour: Any!
    var tourAudio: NSArray!
    
    var audioPlayer: AVAudioPlayer?
    var audioData: NSData!
    var audioDataArray: NSMutableArray!
    
    var audioDataString:String = ""
    
    let dataArray:NSMutableArray = []
    

    override func viewDidLoad() {
        super.viewDidLoad()

//        print(theTour)
        
        
        
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
        
        let myView = UIView(frame: CGRect(x: self.view.center.x - 150, y: self.view.center.y - 250, width: 300, height: 300))
        myView.backgroundColor = UIColor.blue
        let title = 
        self.tourMap.addSubview(myView)
        self.tourMap.bringSubview(toFront: myView)
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
