//
//  SettingsViewController.swift
//  MyProject
//
//  Created by username on 14/09/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation
import UIKit



public class SettingsViewController : UITableViewController, DelegateTableViewController {
    
    @IBOutlet weak var localCurrencyCell: UITableViewCell!
    
    public override func viewDidLoad() {
        
    }
    
    //MARK : DelegateTableViewController
    public func currencyTableViewControllerDelegate(controller: CurrencyTableViewController ){
        
    }
    //MARK : -
    
    
    //MARK : Segue
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == ""){
            
        }
    }
    
    //MARK
    
    //MARK : IBActions
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK : -
    
    
}
