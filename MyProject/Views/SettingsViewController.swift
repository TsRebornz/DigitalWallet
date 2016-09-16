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
        //Load localCurrency FromSettingsManager
        /*
            Enter your code here
        */
    }
    
    //MARK: DelegateTableViewController
    public func currencyTableViewControllerDelegate(controller: CurrencyTableViewController ){
        let localCurrency : CurrencyPrice = controller.selectedCurrency!
        self.localCurrencyCell.textLabel!.text = "\(localCurrency.code!) \(localCurrency.rate!) "
        self.localCurrencyCell.detailTextLabel!.text = "\(localCurrency.name!)"
        //Save this shit to core data
    }
    //MARK: -
    
    //MARK: Segue
    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationVC = segue.destinationViewController as! UINavigationController
        if (segue.identifier == "CurrencySeque"){
            let currencyViewController = navigationVC.topViewController as! CurrencyTableViewController
            currencyViewController.delegate = self
        }
    }
    
    //MARK: -
    
    //MARK: IBActions
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: -
    
    
}
