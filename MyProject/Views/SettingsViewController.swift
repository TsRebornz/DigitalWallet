//
//  SettingsViewController.swift
//  MyProject
//
//  Created by username on 14/09/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation
import UIKit



public class SettingsViewController : UITableViewController {    
    public override func viewDidLoad() {
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
