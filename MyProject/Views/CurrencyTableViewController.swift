//
//  CurrencyTableViewController.swift
//  MyProject
//
//  Created by username on 15/09/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//func datePickerViewDelegate(controller : DatePickerView, sendStringDate stringDate: String  )
public protocol DelegateTableViewController : class {
    func currencyTableViewControllerDelegate(controller: CurrencyTableViewController )
}

public class CurrencyTableViewController : UITableViewController  {
    
    var selectedRate : CurrencyPrice?
    var rates : [CurrencyPrice]?
    public override func viewDidLoad() {
            BlockCypherApi.getCurrencyData({ json in
                let currencyData = CurrencyData(json: json)
                self.rates = currencyData?.data
                self.tableView.reloadData()
            })
    }
    
    //MARK: TableViewMethods
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let t_rates = self.rates else {
            return 0
        }
        return t_rates.count
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId)
        let code = rates![indexPath.row].code!
        let rate = rates![indexPath.row].rate!
        let name = rates![indexPath.row].name!
        cell?.textLabel?.text = " \(code) \(rate) "
        cell?.detailTextLabel?.text = "\(name)"
        return cell!
    }

    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //Mark with galo4ka
        
    }
    
    //MARK: -
    
    //MARK: IBActions
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: -
    
}
