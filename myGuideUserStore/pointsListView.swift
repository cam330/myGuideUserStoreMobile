//
//  pointsListView.swift
//  myGuideUserStore
//
//  Created by Cameron Wilcox on 12/12/16.
//  Copyright © 2016 Cameron Wilcox. All rights reserved.
//

import UIKit

class pointsListView: UIView {

    @IBOutlet var pointsTableView: UITableView!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubview()
    }
    
    func initializeSubview() {
        let xibFileName = "pointsListView"
        let view = Bundle.main.loadNibNamed(xibFileName, owner: self, options:nil)?[0] as! UIView
        
        
        self.addSubview(view)
        view.frame = self.bounds
    }

}
