//
//  ReviewView.swift
//  
//
//  Created by Cameron Wilcox on 12/8/16.
//
//

import UIKit
import Cosmos

class ReviewView: UIView {
    
    @IBOutlet var commentsTextView: UITextView!

    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var starRatingView: CosmosView!
    @IBOutlet var submitButton: UIButton!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
//    
//    class func instanceFromNib() -> UIView {
//        return UINib(nibName: "endRatingView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
//    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubview()
    }
    
    func initializeSubview() {
        let xibFileName = "endRatingView"
        let view = Bundle.main.loadNibNamed(xibFileName, owner: self, options:nil)?[0] as! UIView
        
        self.submitButton.layer.cornerRadius = 15
        self.layer.borderColor = UIColor.black.cgColor
        
        self.addSubview(view)
        view.frame = self.bounds
    }

    
    
}
