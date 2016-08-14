import Foundation
import UIKit

public class SendViewController : UIViewController {
        
    @IBOutlet weak var addressTxtField: UITextField!
    
    @IBOutlet weak var ffLbl : UILabel?
    @IBOutlet weak var hhLbl : UILabel?
    @IBOutlet weak var hLbl : UILabel?
    
    @IBOutlet weak var ffSwitch : UISwitch?
    @IBOutlet weak var hhSwitch : UISwitch?
    @IBOutlet weak var hSwitch : UISwitch?
    
    @IBOutlet weak var amountTxtField: UITextField!
    
    @IBOutlet weak var feeValLbl : UILabel?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func inserBtnTapped(sender: AnyObject) {
        
    }
    
    @IBAction func qrCodeBtnTapped(sender: AnyObject) {
        
    }
    
    @IBAction func acceptTxBtnTapped(sender: AnyObject) {
        
    }
}