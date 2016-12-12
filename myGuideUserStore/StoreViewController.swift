//
//  StoreViewController.swift
//  myGuideUserStore
//
//  Created by Cameron Wilcox on 12/6/16.
//  Copyright © 2016 Cameron Wilcox. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Cosmos

final class TourObj: NSObject {
    
    var tourId : String
    var title: String
    init(tourId: String, title: String) {
        self.tourId = tourId
        self.title = title
    }
}

class TourTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var starView: CosmosView!
    @IBOutlet var tourKeyWordsLabel: UILabel!
    @IBOutlet var tourGuideNameLabel: UILabel!
    var tourId: NSString!
    @IBOutlet var priceLabel: UILabel!
}

class StoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {
    
//    var ref: FIRDatabaseReference!
    let ref = FIRDatabase.database().reference()
    var refHandle: UInt!
    var tourArray: NSMutableArray = []
    var nextArray: NSArray = []
    var passingDict: NSDictionary!
    var tourId: NSString!
    var some:NSMutableArray = []
    var presentingArray: NSArray = []
    var sortingDict: NSDictionary!
    @IBOutlet var likeButton: UIButton!
    var titleName = String()
    let tourObjectArray: NSMutableArray = []
    var sortPicker: sortingView = sortingView()
    
    var alert = UIAlertController()
    
    var countryToSelect: NSString!
    
    let sortOptions = [
        NSSortDescriptor(key: "title", ascending: true,
                          selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))),
        
        NSSortDescriptor(key: "title", ascending: false,
                          selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))),
        
        NSSortDescriptor(key: "tourId", ascending: true,
                          selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))),
        
        NSSortDescriptor(key: "tourId", ascending: false,
                          selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))),
        
        NSSortDescriptor(key: "price", ascending: true,
                          selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))),
        
        NSSortDescriptor(key: "price", ascending: false,
                          selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        ]
    
    let sortWords = ["Title(A-Z)", "Title(Z-A)", "Date Creted(Earliest)", "Date Created(Latest)", "Price(Low - High)", "Price(High - Low)"]
    
    var sortBy = NSSortDescriptor()
    
    var disableView = UIView()

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.countryToSelect as String?
        
        let registeredUserRef = ref.child("tours")
        
        
        
        //Use this to get back all values from china
//        registeredUserRef.queryOrdered(byChild: "country").queryEqual(toValue: "China").observe(.value, with: { firDataSnapshot in
        
//        registeredUserRef.queryOrdered(byChild: "country").observe(.value, with: { firDataSnapshot in
//            let dictionary = firDataSnapshot.value as! NSDictionary
//            let titles = ((((dictionary.allValues as AnyObject?) ?? NSDictionary()) as AnyObject).value(forKey: "title"))
//            let attractions = ((((dictionary.allValues as AnyObject?) ?? NSDictionary()) as AnyObject).value(forKey: "attraction"))
//            
////            print(attractions)
////            print(titles)
//            
//            self.newDict["titles"] = (titles as AnyObject?)!
//            self.newDict["attractions"] = attractions as! NSArray?
//            
//            print(self.newDict)
//
//            self.nextArray = (attractions as! NSArray?)!
//            
////            print(self.nextArray)
//            
//            self.nextArray = (titles as! NSArray?)!
////            print(self.nextArray)
//            
//            self.tableView.reloadData()
//            
//        })
        
        registeredUserRef.observe(.value, with: { snapshot in
            
            self.sortingDict = snapshot.value as! NSDictionary
            
            print("SORTDD",self.sortingDict)
            
            
            
            
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let dict = child.value as! NSDictionary
                let newDict: NSMutableDictionary = NSMutableDictionary()
                
                if (dict.value(forKey: "country") as! String).isEqual(self.countryToSelect) || self.countryToSelect == "All Locations" {
                    
                newDict.setValue(child.key, forKey: "tourId")
                newDict.setValue(dict.value(forKey: "country") ?? NSString(), forKey: "country")
                newDict.setValue(dict.value(forKey: "attraction") ?? NSString(), forKey: "attraction")
                newDict.setValue(dict.value(forKey: "title") ?? NSString(), forKey: "title")
                newDict.setValue(dict.value(forKey: "keyWords") ?? NSString(), forKey: "keys")
//                newDict.setValue(dict.value(forKey: "downloads" ?? NSString(), forKey: "downloads")
                newDict.setValue(dict.value(forKey: "price") ?? NSString(), forKey: "price")
                newDict.setValue(dict.value(forKey: "reviews"), forKey: "reviews")
                    
                let obTitle = dict.value(forKey: "title") ?? String()
//                var obCountry = dict.value(forKey: "country") ?? String()
                let obTourId = child.key
                
                

                let tours = [TourObj(tourId: obTourId, title: obTitle as! String)]
                
                self.tourObjectArray.addObjects(from: tours)
                
//                print("OBJ TEST", self.tourObjectArray)
                let objee:NSObject = newDict
//                print("TEts",objee)
                
                self.passingDict = newDict
//                some.insert(["Country": dict.value(forKey: "country"), "Attraction": dict.value(forKey: "attraction")])
                self.some.insert(newDict, at: 0)
                    
                }
                
            }
//            print("SOME",self.some)
            self.presentingArray = self.some as NSArray
            
//            print(self.passingDict.count)
//            print(self.passingDict)
            self.tableView.reloadData()
            self.alert.dismiss(animated: true, completion: nil)
            
                
        })
 
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    
//        self.alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
//        self.alert.view.tintColor = UIColor.black
//        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:10, y:5, width:50, height:50)) as UIActivityIndicatorView
//        loadingIndicator.hidesWhenStopped = true
//        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
//        loadingIndicator.startAnimating()
//        
//        alert.view.addSubview(loadingIndicator)
//        present(alert, animated: true, completion:nil)
//    
//    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
////        print("CUSH",self.countryToSelect)
//        
//        let registeredUserRef = ref.child("tours").child()
//        print(registeredUserRef)
//    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.sortWords.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.sortWords[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(self.sortWords[row])
        self.sortBy = self.sortOptions[row]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.passingDict.count
        return self.presentingArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath)as! TourTableViewCell
        
        cell.starView.settings.fillMode = .precise
        
        cell.starView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        
        if self.presentingArray.count > 0 {
            cell.tourId = (self.presentingArray[indexPath.row] as AnyObject).value(forKey: "tourId") as! NSString
            cell.titleLabel.text = "\((self.presentingArray[indexPath.row] as AnyObject).value(forKey: "title") as! NSString)"
            cell.tourGuideNameLabel.text = "\((self.presentingArray[indexPath.row] as AnyObject).value(forKey: "attraction") as! NSString),\((self.presentingArray[indexPath.row] as AnyObject).value(forKey: "country") as! NSString)"
            let stringToPresent = ((self.presentingArray[indexPath.row] as AnyObject).value(forKey: "keys") as! NSArray).componentsJoined(by: ", ")
            print(stringToPresent)
            cell.tourKeyWordsLabel.text = "\(stringToPresent)"
            if (self.presentingArray[indexPath.row] as AnyObject).value(forKey: "price") as! String == "Free" {
                cell.priceLabel.text = (self.presentingArray[indexPath.row] as AnyObject).value(forKey: "price") as! String
            } else {
            cell.priceLabel.text = "$\((self.presentingArray[indexPath.row] as AnyObject).value(forKey: "price") as! String)"
            }
            print(cell.tourId)
            let total = ((((self.presentingArray[indexPath.row] as AnyObject).value(forKey: "reviews") ?? String()) as AnyObject).value(forKey: "total")) as! Int
            let count = ((((self.presentingArray[indexPath.row] as AnyObject).value(forKey: "reviews") ?? String()) as AnyObject).value(forKey: "count")) as! Int
//            print((self.presentingArray[indexPath.row] as AnyObject).value(forKey: "reviews")[1])
            cell.starView.rating = Double(total/count)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)as! TourTableViewCell
        
        print(cell.tourId)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.tourId = cell.tourId
        
        [self.performSegue(withIdentifier: "showTourDetails", sender: self)]
    }


    @IBAction func sortResults(sender: UIButton) {

        self.sortPicker = sortingView(frame: CGRect(x:0, y:self.tableView.frame.height - 100 , width:375 , height: 150))
        self.sortPicker.sortButton.addTarget(self, action: #selector(sortTable(sender:)), for: .touchUpInside)
        self.sortPicker.cancelButton.addTarget(self, action: #selector(cancelSort(sender:)), for: .touchUpInside)
        self.disableView = UIView(frame: CGRect(x:0, y:0 , width: self.view.frame.width , height: self.view.frame.height))
        self.disableView.backgroundColor = UIColor.lightGray
        self.disableView.alpha = 0.5
        self.tableView.isUserInteractionEnabled = false
        self.view.addSubview(self.disableView)
        self.view.addSubview(self.sortPicker)
        self.sortPicker.sortPicker.delegate = self
        self.sortPicker.sortPicker.dataSource = self
//        self.view.bringSubview(toFront: self.sortPicker)
        



    }
    
    @IBAction func sortTable(sender: UIButton) {
        self.presentingArray = (self.some as NSArray).sortedArray(using: [self.sortBy]) as NSArray
        
        print("TITLE",self.presentingArray)
        
        self.tableView.reloadData()
        self.sortPicker.removeFromSuperview()
        self.tableView.isUserInteractionEnabled = true
        self.disableView.removeFromSuperview()
        
    }
    
    @IBAction func cancelSort(sender: UIButton) {
        self.sortPicker.removeFromSuperview()
        self.tableView.isUserInteractionEnabled = true
        self.disableView.removeFromSuperview()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTourDetails" {
            let nextScene = segue.destination as? TourDetailViewController
            
            nextScene?.tourId = self.tourId
            

        }
    }
 

}
