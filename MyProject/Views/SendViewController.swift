import Foundation
import UIKit
import SwiftValidator
import LocalAuthentication

public class SendViewController : UIViewController, ValidationDelegate, UITextFieldDelegate, ScanViewControllerDelegate {
    @IBOutlet weak var addressTxtField: UITextField!
    @IBOutlet weak var addressErrorLabel : UILabel!
    
    @IBOutlet weak var ffLbl : UILabel!
    @IBOutlet weak var hhLbl : UILabel!
    @IBOutlet weak var hLbl : UILabel!
    
    @IBOutlet weak var ffSwitch : UISwitch!
    @IBOutlet weak var hhSwitch : UISwitch!
    @IBOutlet weak var hSwitch : UISwitch!
    
    @IBOutlet weak var amountSlider : UISlider!
    @IBOutlet weak var sliderMaxValSatoshiLabl : UILabel!
    @IBOutlet weak var sliderMaxValFiatLabl : UILabel!
    
    @IBOutlet weak var amountErrorLabel: UILabel!
    @IBOutlet weak var amountSatTxtField: UITextField!
    @IBOutlet weak var amountFiatTxtField: UITextField!
    @IBOutlet weak var amountFiatCodeLabel: UILabel!
    
    @IBOutlet weak var feeValSatLbl : UILabel!
    @IBOutlet weak var feeValFiatLbl : UILabel!
    
    let validator = Validator()
        
    var counterTx : Int = 0
    var address : Address!
    var key : BRKey!
    var feeData : Fee!
    let testNet = true    
    
    //TestAddress, using for initialization
    let testAddress = "0000000000000000000000000000"
    
    var scanViewController : ScanViewController!
    var selectedFeeRate : Int!
    var transactionProtocol : TransactionProtocol?
    var minersFeeProtocol : MinersFeeProtocol?
    
    //UISwitch logic variables
    var switchArr : [UISwitch] = []
    var switchDictionary: [UISwitch : UILabel] = [:]
    
    //"transaction.send.response"
    
    //Notifications
    let selectorFeeChanged = "sendviewcontroller.feeData.changed"
    let selectorAmountChanged = "sendviewcontroller.amount.changed"
    
    //FlagForSendOperation
    var addressValid : Bool = false
    var amountValid : Bool = false
    
    //Authentification
    var laContext : LAContext!
    var authenticated = false
    
    //TextField And Slider synchronization
    var uiItemsSynchrArr = [AnyObject]()
    
    //FIXME:Extract to singleton
    var GlobalUserInitiatedQueue: dispatch_queue_t {
        let qualityOfServiceClass = QOS_CLASS_USER_INITIATED
        return dispatch_get_global_queue(qualityOfServiceClass, 0)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //UISwitchLogic
        switchArr += [ffSwitch,hhSwitch,hSwitch]
        switchDictionary = [ self.ffSwitch! : self.ffLbl! , self.hhSwitch! : self.hhLbl! , self.hSwitch! : self.hLbl! ]
        
        ////TextField And Slider synchronization
        self.uiItemsSynchrArr.append([self.amountSlider, self.amountSatTxtField, self.amountFiatTxtField])
        
        self.prepareAndLoadViewData()
        
        //Notifications
        //Need to know when feeData is loaded
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(feeDataChanged), name: selectorFeeChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(amountDataChanged), name: selectorAmountChanged, object: nil)
        
        //Authentication
        self.laContext = LAContext()
        
        //Valiadtion in privateKeyTextField
        validator.registerField(addressTxtField, errorLabel: addressErrorLabel, rules: [RequiredRule(), AddressRule() ])
        validator.registerField(amountSatTxtField, errorLabel: amountErrorLabel, rules: [RequiredRule(), DigitRule() ])
        validator.registerField(amountFiatTxtField, errorLabel: amountErrorLabel, rules: [RequiredRule(), DigitRule() ])
    }
    
    func prepareAndLoadViewData(){
        self.loadSliderData()
        self.updateFeeData()
        self.loadFeeData()
        self.selectedFeeRate = 0
        self.feeValSatLbl.text = "0"
        self.updateFiatData()
        
        addressTxtField.layer.cornerRadius = 5
        addressTxtField.delegate = self
        amountSatTxtField.delegate = self
        amountFiatTxtField.delegate = self
    }
    
    override public func viewWillAppear(animated: Bool) {
        self.scanViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ScanViewController") as! ScanViewController
    }
    
    func createTxDataWithDefaultParameters(){
        //Needs only for initialization
        let defaultFee = 0
        let sendAddress = self.testAddress
        let validKey = self.key!
        let amountSatTxtField = self.amountSatTxtField.text!
        let amount = Int(amountSatTxtField)!
        let testnet = validKey.isTestnetValue()
        let transaction : Transaction = Transaction(address: self.address!, brkey: validKey, sendAddress: sendAddress, fee: defaultFee , amount: amount)
        self.transactionProtocol = transaction
        self.minersFeeProtocol = transaction
        self.minersFeeProtocol?.calculateMinersFee()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:FeeLogic
    func loadFeeData(){
        dispatch_async(GlobalUserInitiatedQueue) {
            BlockCypherApi.getFeeData({ json in
                guard let t_feeData : Fee = Fee(json: json) else {
                    return
                }
                self.feeData = t_feeData
                self.updateFeeData()
                
                self.createTxDataWithDefaultParameters()
                
                self.updateSelectedFeeRate(self.hhSwitch!)
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
    
    func updateFiatData(){
        let cp : CurrencyPrice? = MPManager.sharedInstance.sendData(MPManager.localCurrency) as! CurrencyPrice?
        self.amountFiatCodeLabel.text! = cp != nil ? (cp?.code!)! : "No Data"
    }
    
    func setFeeForSelectedSwitchAndTurnOffSwitchesExcept(switched: UISwitch){
        switched.enabled = false
        self.updateSelectedFeeRate(switched)
        for uiSwitch in self.switchArr{
            if (uiSwitch != switched && uiSwitch.on){
                uiSwitch.enabled = true
                uiSwitch.setOn(false, animated: true)
                break
            }
        }
    }
    
    func updateSelectedFeeRate(switcherSelected: UISwitch){
        let switchLbl : UILabel = switchDictionary[switcherSelected]!
        guard let switchText : String = switchLbl.text! else {
            return
        }
        let oldValue = self.selectedFeeRate
        let newVal = Int( switchText )
        if (newVal != oldValue && nil != newVal) {
            self.selectedFeeRate = newVal
            NSNotificationCenter.defaultCenter().postNotificationName(selectorFeeChanged, object: self, userInfo: nil)
        }
    }
    //MARK:

    //MARK:Slider methods
    func loadSliderData(){
        guard let balance : Int = Int((self.address?.balance)!) else {
            NSException(name: "SendViewControllerAddressNil", reason: "Address or balance is nil", userInfo: nil).raise()
        }
        self.amountSlider.maximumValue = Float(balance)
        self.sliderMaxValSatoshiLabl.text = String(balance)
        self.sliderMaxValFiatLabl.text = getFiatString(balance, withCode: true)
        let defaultVal = Float(balance/10)
        self.amountSlider.setValue( defaultVal , animated: true)
        self.amountSatTxtField.text = "\(Int(defaultVal))"
        self.amountFiatTxtField.text = getFiatString(Int(defaultVal), withCode: false)
    }
    //MARK:
    
    //MARK:ScanViewControllerDelegate
    func DelegateScanViewController(controller: ScanViewController, dataFromQrCode : String?){
        guard let t_dataQrCode = dataFromQrCode else {return}
        self.addressTxtField.text = t_dataQrCode
        validator.validate(self)
    }
    //MARK:
    
    //MARK:TextDelegate
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if(textField == self.amountSatTxtField || textField == self.amountFiatTxtField ) {
            
            validator.validateField(textField){ error in
                //Kostil 2000 b|
                let isAmountNoMoreThanBalance = Int(self.amountSatTxtField.text!) <= Int((self.address.balance)!)
                let isAmountDigitAndNoMoreThanBalance : Bool = error == nil ? isAmountNoMoreThanBalance : false
                if ( isAmountDigitAndNoMoreThanBalance )  {
                    //Field validation was successful
                    //let amount : Int = Int(textField.text!)!
                    self.changeValidatableFieldToDefault(self.amountSatTxtField, errorLbl: self.amountErrorLabel)
                    NSNotificationCenter.defaultCenter().postNotificationName(self.selectorAmountChanged, object: self, userInfo: nil)
                    self.amountValid = true
                    self.synchronizeTxtFields(textField)
                    
                } else {
                    // Validation error occurred
                    let field = self.amountSatTxtField
                    field.layer.borderColor = UIColor.redColor().CGColor
                    field.layer.borderWidth = 1.0
                    //Kostil 2000 b|
                    let errorMessage : String = isAmountNoMoreThanBalance ? "Not number value" : "Amount more than Balance"
                    self.amountErrorLabel.text = errorMessage // works if you added labels
                    self.amountErrorLabel.hidden = false
                    self.amountValid = false
                }
            }
        }else {
            validator.validate(self)
        }
        
        return true
    }
    //MARK:
    
    func synchronizeTxtFields(textField : UITextField) {
        for uiItem in self.uiItemsSynchrArr {
                //Mark: - Zlo
                if  uiItem is UISlider {                    
                    (uiItem as! UISlider).setValue(Float(textField.text!)!, animated: true)
                } else if uiItem is UITextField {
                    (uiItem as! UITextField).text = textField.text
                }
                //Mark: -
        }
    }
    
    func getFiatString(bySatoshi : Int , withCode : Bool) -> String {
        let localCurrency : CurrencyPrice? = MPManager.sharedInstance.sendData(MPManager.localCurrency) as! CurrencyPrice?
        let fiatBalanceString = Utilities.getFiatBalanceString(localCurrency, satoshi: bySatoshi, withCode: withCode)
        let fiatString = fiatBalanceString  != "" ? "\(fiatBalanceString)" : ""
        return fiatString
    }
    
    func changeValidatableFieldToDefault(validateField: UITextField, errorLbl : UILabel){
        validateField.layer.borderColor = UIColor.greenColor().CGColor
        validateField.layer.borderWidth = 1.0
        errorLbl.hidden = true
    }
    
    //MARK:Validation
    public func validationSuccessful(){
        self.addressValid = true
        self.changeValidatableFieldToDefault(self.addressTxtField, errorLbl: self.addressErrorLabel!)
        self.transactionProtocol?.changeSendAddress(self.addressTxtField.text!)
    }
    
    public func validationFailed(errors: [(Validatable, SwiftValidator.ValidationError)]){
        // turn the fields to red
        for (field, error) in errors {
            let field = field as? UITextField
            if (field != self.amountSatTxtField){
                field!.layer.borderColor = UIColor.redColor().CGColor
                field!.layer.borderWidth = 1.0
                error.errorLabel?.text = error.errorMessage // works if you added labels
                error.errorLabel?.hidden = false
                self.addressValid = false
            }
        }
    }
    //MARK:
    
    //MARK:Notifications
    func feeDataChanged() {
        let miners_fee : Int = (self.minersFeeProtocol!.updateMinersFeeWithFee(self.selectedFeeRate))
        self.feeValSatLbl?.text = "\(miners_fee)"
        self.feeValFiatLbl!.text! = self.getFiatString(miners_fee, withCode: true)
    }
    
    func amountDataChanged() {
        let strAmount : String = self.amountSatTxtField.text!
        //changeAmount
        let miners_fee : Int = (self.minersFeeProtocol!.updateMinersFeeWithAmount(Int(strAmount)!))
        self.feeValSatLbl?.text = "\(miners_fee)"
        self.feeValFiatLbl!.text! = self.getFiatString(miners_fee, withCode: true)
    }
    //MARK:
    
    //MARK: Authentification
    
    func authenticateUser( reasonString: String,  succes: ( authSucces : Bool ) -> Void ) {
        var laError : NSError?
        let reasonString = reasonString
        var auth = false
        if (laContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthentication, error: &laError)){
            laContext.evaluatePolicy(LAPolicy.DeviceOwnerAuthentication, localizedReason: reasonString, reply: { (success: Bool, error: NSError?) -> Void in
                if (success) {
                    auth = true
                }
                succes(authSucces: auth)
            })
        } else {
            succes(authSucces: auth)
        }
    }
    
    //MARK:
    
    //MARK:Actions
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
        self.amountSatTxtField.text = String(intValue)
        self.amountFiatTxtField.text = self.getFiatString(intValue, withCode: false)
        self.changeValidatableFieldToDefault(self.amountSatTxtField, errorLbl: self.amountErrorLabel!)
        self.changeValidatableFieldToDefault(self.amountFiatTxtField, errorLbl: self.amountErrorLabel!)
        NSNotificationCenter.defaultCenter().postNotificationName(self.selectorAmountChanged, object: self, userInfo: nil)
    }
    
    @IBAction func acceptTxBtnTapped(sender: AnyObject) {
        validator.validate(self)
        textFieldShouldReturn(self.amountSatTxtField)
        
        let alertController = UIAlertController(title: "Send Transaction Error", message: "Error not all properties are valid", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:{ UIAlertAction in
            //b|
        })
        alertController.addAction(cancelAction)
        
        if (addressValid && amountValid){
            let reasonString = "Authenticate yourself \nYou want to send \(self.amountSatTxtField!.text!)(\(self.amountFiatTxtField!.text!)) \nTo address \(self.addressTxtField!.text!)\nWith miners fee \(self.feeValSatLbl!.text!)(\(self.feeValFiatLbl!.text!))"
            self.authenticateUser(reasonString, succes: { auth in
                if auth {
                    self.counterTx = self.counterTx + 1
                    print("Counter equals \(self.counterTx)")
                    self.transactionProtocol?.createTransaction()
                    self.transactionProtocol?.signTransaction()
                    self.transactionProtocol?.sendTransaction({ response in
                        alertController.message = "Authentication is successfull Transaction Sended"
                        self.presentViewController(alertController, animated: true, completion: nil)
                        //self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            })
        } else {
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    //MARK:
    
}