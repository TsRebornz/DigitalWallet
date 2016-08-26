import Foundation
import UIKit
import SwiftValidator

public class SendViewController : UIViewController, ValidationDelegate, UITextFieldDelegate, ScanViewControllerDelegate {
        
    // errorLabel
    @IBOutlet weak var addressTxtField: UITextField!
    @IBOutlet weak var addressErrorLabel : UILabel?
    
    @IBOutlet weak var ffLbl : UILabel?
    @IBOutlet weak var hhLbl : UILabel?
    @IBOutlet weak var hLbl : UILabel?
    
    @IBOutlet weak var ffSwitch : UISwitch?
    @IBOutlet weak var hhSwitch : UISwitch?
    @IBOutlet weak var hSwitch : UISwitch?
    
    
    @IBOutlet weak var amountErrorLabel: UILabel!
    @IBOutlet weak var amountTxtField: UITextField!    
    
    @IBOutlet weak var feeValLbl : UILabel?
    
    let validator = Validator()
    
    var address : Address?
    var feeData : Fee?
    
    var scanViewController : ScanViewController!
    
    var selectedFeeRate : Int!
    
    var switchArr : [UISwitch?] = []
    
    var switchDictionary: [UISwitch : UILabel] = [:]
    
    var GlobalUserInitiatedQueue: dispatch_queue_t {
        let qualityOfServiceClass = QOS_CLASS_USER_INITIATED
        return dispatch_get_global_queue(qualityOfServiceClass, 0)
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //UISwitchLogic
        switchArr += [ffSwitch,hhSwitch,hSwitch]
        switchDictionary = [ self.ffSwitch! : self.ffLbl! , self.hhSwitch! : self.hhLbl! , self.hSwitch! : self.hLbl! ]
        
        self.updateselectedFeeRate(self.hhSwitch!)
        
        self.prepareAndLoadViewData()
        
        //Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(calculateMinersFeeByAmountAndFeeRate), name: "sendviewcontroller.validation.succes", object: nil)
        
        //Valiadtion in privateKeyTextField
        validator.registerField(addressTxtField, errorLabel: addressErrorLabel, rules: [RequiredRule(), AddressRule() ])
        validator.registerField(amountTxtField, errorLabel: amountErrorLabel, rules: [RequiredRule(), DigitRule() ])
    }
    
    func prepareAndLoadViewData(){
        self.updateFeeData()
        self.updateMinersFee()
        self.loadFeeData()
        self.selectedFeeRate = 0
        addressTxtField.layer.cornerRadius = 5
        addressTxtField.delegate = self
        amountTxtField.delegate = self
    }
    
    override public func viewWillAppear(animated: Bool) {
        self.scanViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ScanViewController") as! ScanViewController
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
    
    func setFeeForSelectedSwitchAndTurnOffSwitchesExcept(switched: UISwitch){
            self.updateselectedFeeRate(switched)
            for uiSwitch in self.switchArr{
                if (uiSwitch! != switched && uiSwitch!.on){
                    uiSwitch?.enabled = true
                    uiSwitch?.setOn(false, animated: true)
                }
            }
    }
    
    func updateselectedFeeRate(switcherSelected: UISwitch){
        switcherSelected.enabled = false
        let switchLbl = switchDictionary[switcherSelected]
        guard let switchText : String = switchLbl?.text! else {
            return
        }
        self.selectedFeeRate = Int( switchText )
    }
    
    func calculateMinersFeeByAmountAndFeeRate( feeRate : Int , amount : Int ) {
        print("\n\nЫЫЫЫЫЫ\n\n")
    }
    
    
    //ScanViewControllerDelegate
    
    func DelegateScanViewController(controller: ScanViewController, dataFromQrCode : String?){
        guard let t_dataQrCode = dataFromQrCode else {return}
        self.addressTxtField.text = t_dataQrCode
        validator.validate(self)
    }
    
    //End
    
    //TextDelegate
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if(textField == self.amountTxtField) {
            validator.validateField(textField){ error in
                if error == nil {
                    //Field validation was successful
                    let amount : Int = Int(textField.text!)!
                    self.amountTxtField.layer.borderColor = UIColor.greenColor().CGColor
                    self.amountTxtField.layer.borderWidth = 1.0
                    self.amountErrorLabel.hidden = true
                    self.calculateMinersFeeByAmountAndFeeRate(self.selectedFeeRate, amount: amount )
                    
                } else {
                    // Validation error occurred
                    let field = error?.field as? UITextField
                    field!.layer.borderColor = UIColor.redColor().CGColor
                    field!.layer.borderWidth = 1.0
                    error!.errorLabel?.text = error!.errorMessage // works if you added labels
                    error!.errorLabel?.hidden = false
                }
            }
        }
        
        
        return true
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        
        if textField == self.addressTxtField {

        }else if textField == self.amountTxtField {
//            guard let text : String = self.amountTxtField.text else {
//                return
//            }
//            calculateMinersFeeByAmountAndFeeRate(self.selectedFeeRate , amount: Int(text)! )
        }

        
    }
    //End
    
    //Validtion
    public func validationSuccessful(){
            addressTxtField.layer.borderColor = UIColor.greenColor().CGColor
            addressTxtField.layer.borderWidth = 1.0
            addressErrorLabel!.hidden = true
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

    @IBAction func qrCodeBtnTapped(sender: AnyObject) {
        self.scanViewController.delegate = self
        self.navigationController?.presentViewController(self.scanViewController , animated: true, completion: nil)
    }
    
    @IBAction func ffSwitched(sender: UISwitch) {
        setFeeForSelectedSwitchAndTurnOffSwitchesExcept(sender)
    }
    
    @IBAction func hhSwitched(sender: UISwitch) {
        setFeeForSelectedSwitchAndTurnOffSwitchesExcept(sender)
    }
    
    @IBAction func hSwitched(sender: UISwitch) {
        setFeeForSelectedSwitchAndTurnOffSwitchesExcept(sender)
    }
    
    
    @IBAction func acceptTxBtnTapped(sender: AnyObject) {
        
    }
    //End
    
}