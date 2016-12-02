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
import AVFoundation

class ViewController: UIViewController {
    
//    let storage = FIRStorage.storage()
    let ref = FIRDatabase.database().reference()
    var tourArray: NSMutableArray = []
    var audioDataArray: NSMutableArray = []
    var audioDataString:String = ""
    var audioPlayer: AVAudioPlayer?
    var audioData: NSData!

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
            
//            print((passingArray as! NSArray?)?.count ?? NSNumber())
            let arrayCount = (passingArray as! NSArray?)?.count
            print(arrayCount ?? NSNumber())
            
            for i in 0 ..< arrayCount! {
                let partitionArray = (passingArray as! NSArray?)![i]
                
                self.audioDataString = String(format: "%@", partitionArray as! CVarArg)
                
                
                //            var data = Data.fromBase64String(self.audioDataString)
                
                self.audioData = NSData(base64Encoded: self.audioDataString, options: [])!
            
                self.audioDataArray.add(self.audioData)
            }
            
//            let partitionArray = (passingArray as! NSArray?)![1]
//            
//            self.audioDataString = String(format: "%@", partitionArray as! CVarArg)
//            
//            
////            var data = Data.fromBase64String(self.audioDataString)
//           
//            self.audioData = NSData(base64Encoded: self.audioDataString, options: [])!
            print(self.audioDataArray)
            

            
            
//            print("TEST3",passingArray ?? String())
        })
    }
    
    @IBAction func showData(_ sender: Any) {
        
        self.audioPlayer = try! AVAudioPlayer(data: self.audioData as Data, fileTypeHint: AVFileTypeWAVE)
        self.audioPlayer?.prepareToPlay()
        self.audioPlayer?.play()
    }

}

