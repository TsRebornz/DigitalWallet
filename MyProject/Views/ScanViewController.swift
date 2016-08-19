//
//  ScanViewController.swift
//  MyProject
//
//  Created by username on 19/08/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation
import UIKit

protocol ScanViewControllerDelegate : class {
    func DelegateScanViewController(controller: ScanViewController)
}

public class ScanViewController : UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    
    var dataFromCamera : String!
    
    public override func viewDidLoad() {
        //code
    }
    
    public override func viewWillAppear(animated: Bool) {
        
    }
    
    public override func viewDidDisappear(animated: Bool) {
     
    }
    
    @IBAction func backBtnTapped(sender: UIBarButtonItem) {        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
    

