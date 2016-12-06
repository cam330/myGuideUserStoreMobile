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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //    let storage = FIRStorage.storage()
    let ref = FIRDatabase.database().reference()
    var tourArray: NSMutableArray = []
    var audioDataArray: NSMutableArray = []
    var audioDataString:String = ""
    var audioPlayer: AVAudioPlayer?
    var audioData: NSData!
    var selectedAudio: NSNumber!
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let conditionRef = ref.child("tours").child("france")
        
        conditionRef.observe(FIRDataEventType.value, with: {(snapshot) in
            
            print("COMPLETE")
        })
        
        
        
        conditionRef.observe(.value, with: { snapshot in
            
            self.tourArray.add((((snapshot.value as AnyObject).value(forKey: "array")) as AnyObject).value(forKey: "title") ?? String())
            
            let array = [self.tourArray.lastObject!]
            
            print(array[0])
            
            let passingArray = ((((snapshot.value as AnyObject).value(forKey: "array")) as AnyObject).value(forKey: "audio"))
            
            let arrayCount = (passingArray as! NSArray?)?.count
            print(arrayCount ?? NSNumber())
            
            for i in 0 ..< arrayCount! {
                let partitionArray = (passingArray as! NSArray?)![i]
                
                self.audioDataString = String(format: "%@", partitionArray as! CVarArg)
                
                self.audioData = NSData(base64Encoded: self.audioDataString, options: [])!
                
                self.audioDataArray.add(self.audioData)
                
                
            }
            
            print(self.audioDataArray)
            self.tableView.reloadData()
            
        })
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.audioDataArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        cell.textLabel?.text = String(format: "%d", indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        self.selectedAudio = indexPath.row as NSNumber!
        print(self.selectedAudio)
        
        let indexToPlay = self.selectedAudio.intValue
        
        self.audioPlayer = try! AVAudioPlayer(data: self.audioDataArray[indexToPlay] as! Data, fileTypeHint: AVFileTypeWAVE)
        self.audioPlayer?.prepareToPlay()
        self.audioPlayer?.play()
        
    }
    
}
