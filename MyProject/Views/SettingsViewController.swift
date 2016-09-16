//
//  SettingsViewController.swift
//  MyProject
//
//  Created by username on 14/09/16.
//  Copyright © 2016 BCA. All rights reserved.

import Foundation
import UIKit

public class SettingsViewController : UITableViewController, DelegateTableViewController  {
    
    @IBOutlet weak var localCurrencyCell: UITableViewCell!
    
    
    
    public override func viewDidLoad() {
        //Load localCurrency FromSettingsManager
        MPManager.sharedInstance.settingsVC = self
        self.loadLocalCurrencyData()
    }
    
    //MARK: DelegateTableViewController
    public func currencyTableViewControllerDelegate(controller: CurrencyTableViewController ){
        let localCurrency : CurrencyPrice = controller.selectedCurrency!
        updateCellbyModel( localCurrency )
        MPManager.sharedInstance.valueChanged(MPManager.localCurrency, value: localCurrency as AnyObject)
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
    
    func loadLocalCurrencyData(){
        let t_localCurrency : CurrencyPrice?  = MPManager.sharedInstance.sendData(MPManager.localCurrency) as! CurrencyPrice?
        updateCellbyModel(t_localCurrency)
    }
    
    func updateCellbyModel(model : CurrencyPrice?) {
        if model != nil {
            self.localCurrencyCell.textLabel!.text = "\(model!.code!) \(model!.rate!) "
            self.localCurrencyCell.detailTextLabel!.text = "\(model!.name!)"
        } else {
            self.localCurrencyCell.textLabel!.text = "No currency loaded"
            self.localCurrencyCell.detailTextLabel!.text = ""
            
        }
    }
    
    
}
