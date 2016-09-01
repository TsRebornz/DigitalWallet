import Foundation
import UIKit
import SwiftValidator

public class SendViewController : UIViewController, ValidationDelegate, UITextFieldDelegate, ScanViewControllerDelegate {
    
    @IBOutlet weak var addressTxtField: UITextField!
    @IBOutlet weak var addressErrorLabel : UILabel?
    
    @IBOutlet weak var ffLbl : UILabel?
    @IBOutlet weak var hhLbl : UILabel?
    @IBOutlet weak var hLbl : UILabel?
    
    @IBOutlet weak var ffSwitch : UISwitch?
    @IBOutlet weak var hhSwitch : UISwitch?
    @IBOutlet weak var hSwitch : UISwitch?
    
    
    @IBOutlet weak var amountSlider : UISlider!
    @IBOutlet weak var sliderMaxValLabl : UILabel!
    
    @IBOutlet weak var amountErrorLabel: UILabel!
    @IBOutlet weak var amountTxtField: UITextField!    
    
    @IBOutlet weak var feeValLbl : UILabel?
    
    
    let validator = Validator()
    
    //It this values will be nil all view fuck up
    var address : Address?
    var key : BRKey?
    let testNet = true
    
    var feeData : Fee?
    
    //testAddressUsing if no address in addressTextField
    let testAddress = "moVeRgCBbJj1w7nhzzoSCffVJTpwH8N8SH"
    
    var scanViewController : ScanViewController!
    
    var selectedFeeRate : Int!
    
    var transactionProtocol : TransactionProtocol?
    
    //UISwitch variables
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
        
        self.prepareAndLoadViewData()
        
        self.updateselectedFeeRate(self.hhSwitch!)
        
        self.createTxDataWithDefaultParameters()
        self.calculateAndUpdateMinersFee()
        
        //Notifications
        //Need to know when feeData is loaded
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(calculateMinersFeeByAmountAndFeeRate), name: "sendviewcontroller.validation.succes", object: nil)
        
        //Valiadtion in privateKeyTextField
        validator.registerField(addressTxtField, errorLabel: addressErrorLabel, rules: [RequiredRule(), AddressRule() ])
        validator.registerField(amountTxtField, errorLabel: amountErrorLabel, rules: [RequiredRule(), DigitRule() ])
    }
    
    func prepareAndLoadViewData(){
        self.loadSliderData()
        self.updateFeeData()
        self.updateMinersFee()
        self.loadFeeData()
        self.selectedFeeRate = 0
        self.amountTxtField.text = self.amountTxtField.text! == "" || self.amountTxtField.text == nil  ? "0" : self.amountTxtField.text!
        addressTxtField.layer.cornerRadius = 5
        addressTxtField.delegate = self
        amountTxtField.delegate = self        
    }
    
    func createTxDataWithDefaultParameters(){
        let testFeeRate = 60
        let sendAddress = self.testAddress
        let validKey = self.key!
        let amountString = self.amountTxtField.text!
        let amount = Int(amountString)!
        let testnet = validKey.isTestnetValue()
        //self.transactionProtocol! = Transaction(address: self.address!, brkey: validKey, sendAddress: sendAddress, fee: testFeeRate, amount: amount, testnet: testnet)
        let transaction : Transaction = Transaction(address: self.address!, brkey: validKey, sendAddress: sendAddress, fee: testFeeRate, amount: amount, testnet: testnet)
        self.transactionProtocol = transaction
        self.transactionProtocol!.prepareMetaDataForTx()
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
                // Need to post notification when data is loaded
                //NSNotificationCenter.defaultCenter().postNotificationName(<#T##aName: String##String#>, object: <#T##AnyObject?#>, userInfo: <#T##[NSObject : AnyObject]?#>)
            })
        }
    }
    
    func loadSliderData(){
        guard let balance : Int = Int((self.address?.balance)!) else {
            NSException(name: "SendViewControllerAddressNil", reason: "Address or balance is nil", userInfo: nil).raise()
        }
        self.amountSlider.maximumValue = Float(balance)
        self.sliderMaxValLabl.text = String(balance)
        let defaultVal = Float(balance/10)
        self.amountSlider.setValue( defaultVal , animated: true)
        self.amountTxtField.text = "\(Int(defaultVal))"
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
    
    func calculateAndUpdateMinersFee() {
        let miners_fee : Int = (self.transactionProtocol?.calculateMinersFee())!
        self.feeValLbl?.text = String(miners_fee)
        //guard self
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
                    self.changeValidatableFieldToDefault(self.amountTxtField, errorLbl: self.amountErrorLabel)
                    // Reoptimize Inputs by new Amount
                    // Updatate optimizes inputs in TxData
                    
                    //self.calculateMinersFeeByAmountAndFeeRate(self.selectedFeeRate, amount: amount )
                    
                } else {
                    // Validation error occurred
                    let field = error?.field as? UITextField
                    field!.layer.borderColor = UIColor.redColor().CGColor
                    field!.layer.borderWidth = 1.0
                    error!.errorLabel?.text = error!.errorMessage // works if you added labels
                    error!.errorLabel?.hidden = false
                }
            }
        }else {
            validator.validate(self)
        }
        
        return true
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    //End
    
    func changeValidatableFieldToDefault(validateField: UITextField, errorLbl : UILabel){
        validateField.layer.borderColor = UIColor.greenColor().CGColor
        validateField.layer.borderWidth = 1.0
        errorLbl.hidden = true
    }
    
    //Validtion
    public func validationSuccessful(){
        self.changeValidatableFieldToDefault(self.addressTxtField, errorLbl: self.addressErrorLabel!)
    }
    
    public func validationFailed(errors: [(Validatable, SwiftValidator.ValidationError)]){
        // turn the fields to red
        for (field, error) in errors {
            let field = field as? UITextField
            if (field != self.amountTxtField){
                field!.layer.borderColor = UIColor.redColor().CGColor
                field!.layer.borderWidth = 1.0
                error.errorLabel?.text = error.errorMessage // works if you added labels
                error.errorLabel?.hidden = false
            }
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
    
    
    @IBAction func sliderChanged(sender: UISlider) {
        let intValue = Int(sender.value)
        self.amountTxtField.text = String(intValue)
        self.changeValidatableFieldToDefault(self.amountTxtField, errorLbl: self.amountErrorLabel!)
    }
    
    
    @IBAction func acceptTxBtnTapped(sender: AnyObject) {
        
    }
    //End
    
}