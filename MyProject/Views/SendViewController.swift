import Foundation
import UIKit
import SwiftValidator

public class SendViewController : UIViewController, ValidationDelegate, UITextFieldDelegate {
        
    @IBOutlet weak var addressTxtField: UITextField!
    @IBOutlet weak var errorLabel : UILabel?
    
    @IBOutlet weak var ffLbl : UILabel?
    @IBOutlet weak var hhLbl : UILabel?
    @IBOutlet weak var hLbl : UILabel?
    
    @IBOutlet weak var ffSwitch : UISwitch?
    @IBOutlet weak var hhSwitch : UISwitch?
    @IBOutlet weak var hSwitch : UISwitch?
    
    @IBOutlet weak var amountTxtField: UITextField!
    
    @IBOutlet weak var feeValLbl : UILabel?
    
    let validator = Validator()
    
    var address : Address?
    var feeData : Fee?
    
    var GlobalUserInitiatedQueue: dispatch_queue_t {
        let qualityOfServiceClass = QOS_CLASS_USER_INITIATED
        return dispatch_get_global_queue(qualityOfServiceClass, 0)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.updateFeeData()
        self.updateMinersFee()
        self.loadFeeData()
        addressTxtField.layer.cornerRadius = 5
        addressTxtField.delegate = self        
        
        //Valiadtion in privateKeyTextField
        validator.registerField(addressTxtField, errorLabel: errorLabel, rules: [RequiredRule(), AddressRule() ])
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadFeeData(){
        dispatch_async(GlobalUserInitiatedQueue) {
            BlockCypherApi.getFeeData({ json in
                guard let t_feeData : Fee = Fee(json: json) else {
                    return
                }
                self.feeData = t_feeData
                self.updateFeeData()
            })
        }
    }
    
    func updateFeeData(){
        if( nil != self.feeData?.fastestFee){
            self.ffLbl?.text = String(self.feeData!.fastestFee!)
            self.hhLbl?.text = String(self.feeData!.halfHourFee!)
            self.hLbl?.text = String(self.feeData!.hourFee!)
        }else{
            self.ffLbl?.text = "NO"
            self.hhLbl?.text = "NO"
            self.hLbl?.text = "NO"
        }
    }
    
    func updateMinersFee(){
        self.feeValLbl?.text = "0"
    }
    
    //TextDelegate
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        validator.validate(self)
    }
    //End
    
    //Validtion
    public func validationSuccessful(){
        //nextBtn.enabled = true
        addressTxtField.layer.borderColor = UIColor.greenColor().CGColor
        addressTxtField.layer.borderWidth = 1.0
        errorLabel!.hidden = true
    }
    
    public func validationFailed(errors: [(Validatable, SwiftValidator.ValidationError)]){
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.redColor().CGColor
                field.layer.borderWidth = 1.0
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.hidden = false            
        }
    }
    //End
    
    //Actions
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func inserBtnTapped(sender: AnyObject) {
        let pasteBoard = UIPasteboard.generalPasteboard().strings
        if  ((addressTxtField.text?.isEmpty) != nil){
            addressTxtField?.text = ""
        }
        addressTxtField?.text = pasteBoard?.last
        validator.validate(self)
    }
    
//    @IBAction func insertDataFromPasteBoard() {
//        let pasteBoard = UIPasteboard.generalPasteboard().strings
//        if  ((privateKeyTextField.text?.isEmpty) != nil){
//            privateKeyTextField?.text = ""
//        }
//        privateKeyTextField?.text = pasteBoard?.last
//        validator.validate(self)
//    }
    
    @IBAction func qrCodeBtnTapped(sender: AnyObject) {
        
    }
    
    @IBAction func acceptTxBtnTapped(sender: AnyObject) {
        
    }
    //End
}