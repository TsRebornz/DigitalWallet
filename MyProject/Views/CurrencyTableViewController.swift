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
    
    weak var delegate : DelegateTableViewController?
    var selectedCurrency : CurrencyPrice?
    var rates : [CurrencyPrice]?
    public override func viewDidLoad() {
            BlockCypherApi.getCurrencyData(doWithJson: { json in
                let currencyData = CurrencyData(json: json)
                self.rates = currencyData?.data
                self.tableView.reloadData()
            })
    }
    
    //MARK: TableViewMethods
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let t_rates = self.rates else {
            return 0
        }
        return t_rates.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "CellCurrencyRate"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        let code = rates![indexPath.row].code!
        let rate = rates![indexPath.row].rate!
        let name = rates![indexPath.row].name!
        
        //rate
        (cell?.viewWithTag(1000) as! UILabel).text = "\(code) \(round(rate * 1000) / 1000) "
        (cell?.viewWithTag(1001) as! UILabel).text = "\(name)"
        (cell?.viewWithTag(1002) as! UILabel).text = ""        
        return cell!
    }
    

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Mark with galo4ka
        selectedCurrency = rates![indexPath.row]
        delegate?.currencyTableViewControllerDelegate(controller: self)
        self.dismiss(animated: true, completion: nil)
    }
    
    public func prepareCell(lbl : UILabel , check : Bool) -> UILabel{
        if (check) {
            lbl.text = "√"
        } else {
            lbl.text = ""
        }
        return lbl
    }
    
    //MARK: -
    
    //MARK: IBActions
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: -
    
}
