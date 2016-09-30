import Foundation
import UIKit
import SwiftValidator
import LocalAuthentication

public class SendViewController : UIViewController, UITextFieldDelegate, ValidationDelegate, ScanViewControllerDelegate {
    /**
     This method will be called on delegate object when validation fails.
     
     - returns: No return value.
     */
    
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
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //UISwitchLogic
        switchArr += [ffSwitch,hhSwitch,hSwitch]
        switchDictionary = [ self.ffSwitch! : self.ffLbl! , self.hhSwitch! : self.hhLbl! , self.hSwitch! : self.hLbl! ]
        
        ////TextField And Slider synchronization
        //self.uiItemsSynchrArr += [self.amountSlider , self.amountSatTxtField , self.amountFiatTxtField ]
        self.uiItemsSynchrArr.append(self.amountSlider)
        self.uiItemsSynchrArr.append(self.amountSatTxtField)
        self.uiItemsSynchrArr.append(self.amountFiatTxtField)
        
       
        self.prepareAndLoadViewData()
        
        //Notifications
        //Need to know when feeData is loaded
        NotificationCenter.default.addObserver(self, selector: #selector(feeDataChanged), name: NSNotification.Name(rawValue: selectorFeeChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(amountDataChanged), name: NSNotification.Name(rawValue: selectorAmountChanged), object: nil)
        
        //Authentication
        self.laContext = LAContext()
        
        //Valiadtion in privateKeyTextField
        
        validator.registerField(field: addressTxtField, errorLabel: addressErrorLabel, rules: [RequiredRule(), AddressRule() ])
        validator.registerField(field: amountSatTxtField, errorLabel: amountErrorLabel, rules: [RequiredRule(), DigitRule() ])
        validator.registerField(field: amountFiatTxtField, errorLabel: amountErrorLabel, rules: [RequiredRule(), DecimalRule() ])
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
    
    override public func viewWillAppear(_ animated: Bool) {
        self.scanViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
    }
    
    func createTxDataWithDefaultParameters(){
        //Needs only for initialization
        let defaultFee = 0
        let sendAddress = self.testAddress
        let validKey = self.key!
        let amountSatTxtField = self.amountSatTxtField.text!
        let amount = Int(amountSatTxtField)!        
        let transaction : Transaction = Transaction(address: self.address!, brkey: validKey, sendAddress: sendAddress, fee: defaultFee , amount: amount)
        self.transactionProtocol = transaction
        self.minersFeeProtocol = transaction
        //FIXME: delete after tests
        self.minersFeeProtocol?.calculateMinersFee()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:FeeLogic
    func loadFeeData(){
        let userInitiatedQueue = GCDManager.sharedInstance.getQueue(byQoS: DispatchQoS.userInitiated)
        
        userInitiatedQueue.async {
            BlockCypherApi.getFeeData(doWithJson: { json in
                guard let t_feeData : Fee = Fee(json: json) else {
                    return
                }
                self.feeData = t_feeData
                self.updateFeeData()
                
                self.createTxDataWithDefaultParameters()
                
                self.updateSelectedFeeRate(switcherSelected: self.hhSwitch!)
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
        let cp : CurrencyPrice? = MPManager.sharedInstance.sendData(byString: MPManager.localCurrency) as! CurrencyPrice?
        self.amountFiatCodeLabel.text! = cp != nil ? (cp?.code!)! : "No Data"
    }
    
    func setFeeForSelectedSwitchAndTurnOffSwitchesExcept(switched: UISwitch){
        switched.isEnabled = false
        self.updateSelectedFeeRate(switcherSelected: switched)
        for uiSwitch in self.switchArr{
            if (uiSwitch != switched && uiSwitch.isOn){
                uiSwitch.isEnabled = true
                uiSwitch.setOn(false, animated: true)
                break
            }
        }
    }
    
    func updateSelectedFeeRate(switcherSelected: UISwitch){
        let switchLbl : UILabel = switchDictionary[switcherSelected]!
        guard let switchText : String = switchLbl.text! as String else {
            return
        }
        let oldValue = self.selectedFeeRate
        let newVal = Int( switchText )
        if (newVal != oldValue && nil != newVal) {
            self.selectedFeeRate = newVal
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: selectorFeeChanged), object: self)
        }
    }
    //MARK:

    //MARK:Slider methods
    func loadSliderData(){
        guard let balance : Int = Int((self.address?.balance)!) else {
            NSException(name: NSExceptionName(rawValue: "SendViewControllerAddressNil"), reason: "Address or balance is nil", userInfo: nil).raise()
        }
        self.amountSlider.maximumValue = Float(balance)
        self.sliderMaxValSatoshiLabl.text = String(balance)
        self.sliderMaxValFiatLabl.text = getFiatString(bySatoshi: balance, withCode: true)
        let defaultVal = Float(balance/10)
        self.amountSlider.setValue( defaultVal , animated: true)
        self.amountSatTxtField.text = "\(Int(defaultVal))"
        self.amountFiatTxtField.text = getFiatString(bySatoshi: Int(defaultVal), withCode: false)
    }
    //MARK:
    
    //MARK:ScanViewControllerDelegate
    func DelegateScanViewController(controller: ScanViewController, dataFromQrCode : String?){
        guard let t_dataQrCode = dataFromQrCode else {return}
        self.addressTxtField.text = t_dataQrCode
        
        validator.validate(delegate: self as! ValidationDelegate)
    }
    //MARK:
    
    //MARK:TextDelegate
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if(textField == self.amountSatTxtField || textField == self.amountFiatTxtField ) {
            
            validator.validateField(field: textField){ error in
                //Kostil 2000 b|
                let isAmountNoMoreThanBalance = Int(self.amountSatTxtField.text!)! <= Int((self.address.balance)!)
                let isAmountDigitAndNoMoreThanBalance : Bool = error == nil ? isAmountNoMoreThanBalance : false
                if ( isAmountDigitAndNoMoreThanBalance )  {
                    //Field validation was successful
                    //let amount : Int = Int(textField.text!)!
                    self.changeValidatableFieldToDefault(validateField: self.amountSatTxtField, errorLbl: self.amountErrorLabel)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.selectorAmountChanged), object: self)
                    self.amountValid = true
                    self.synchronizeTxtFields(textField: textField)
                    
                } else {
                    // Validation error occurred
                    let field = self.amountSatTxtField
                    field?.layer.borderColor = UIColor.red.cgColor
                    field?.layer.borderWidth = 1.0
                    //Kostil 2000 b|
                    let errorMessage : String = isAmountNoMoreThanBalance ? "Not number value" : "Amount more than Balance"
                    self.amountErrorLabel.text = errorMessage // works if you added labels
                    self.amountErrorLabel.isHidden = false
                    self.amountValid = false
                }
            }
        }else {
            validator.validate(delegate: self as! ValidationDelegate)
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
        let localCurrency : CurrencyPrice? = MPManager.sharedInstance.sendData(byString: MPManager.localCurrency) as! CurrencyPrice?
        let fiatBalanceString = Utilities.getFiatBalanceString(model: localCurrency, satoshi: bySatoshi, withCode: withCode)
        let fiatString = fiatBalanceString  != "" ? "\(fiatBalanceString)" : ""
        return fiatString
    }
    
    func changeValidatableFieldToDefault(validateField: UITextField, errorLbl : UILabel){
        validateField.layer.borderColor = UIColor.green.cgColor
        validateField.layer.borderWidth = 1.0
        errorLbl.isHidden = true
    }
    
    //MARK:Validation
    public func validationSuccessful(){
        self.addressValid = true
        self.changeValidatableFieldToDefault(validateField: self.addressTxtField, errorLbl: self.addressErrorLabel!)
        self.transactionProtocol?.changeSendAddress(newAddress: self.addressTxtField.text!)
    }
    
    public func validationFailed(errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            let field = field as? UITextField
            if (field != self.amountSatTxtField){
                field!.layer.borderColor = UIColor.red.cgColor
                field!.layer.borderWidth = 1.0
                error.errorLabel?.text = error.errorMessage // works if you added labels
                error.errorLabel?.isHidden = false
                self.addressValid = false
            }
        }
    }
        
    //MARK:
    
    //MARK:Notifications
    func feeDataChanged() {
        let miners_fee : Int = (self.minersFeeProtocol!.updateMinersFeeWithFee(newFeeRate: self.selectedFeeRate))
        self.feeValSatLbl?.text = "\(miners_fee)"
        self.feeValFiatLbl!.text! = self.getFiatString(bySatoshi: miners_fee, withCode: true)
    }
    
    func amountDataChanged() {
        let strAmount : String = self.amountSatTxtField.text!
        //changeAmount
        let miners_fee : Int = (self.minersFeeProtocol!.updateMinersFeeWithAmount(newAmount: Int(strAmount)!))
        self.feeValSatLbl?.text = "\(miners_fee)"
        self.feeValFiatLbl!.text! = self.getFiatString(bySatoshi: miners_fee, withCode: true)
    }
    //MARK:
    
    //MARK: Authentification
    
    func authenticateUser( reasonString: String,  succes: @escaping ( _ authSucces : Bool ) -> Void ) {
        var laError : NSError?
        let reasonString = reasonString
        var auth = false
        if (laContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &laError)){
            laContext.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reasonString, reply: { (success: Bool, error: NSError?) -> Void in
                if (success) {
                    auth = true
                }
                succes(auth)
            } as! (Bool, Error?) -> Void)
        } else {
            succes(auth)
        }
    }
    
    //MARK:
    
    //MARK:Actions
    @IBAction func cancel(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func inserBtnTapped(sender: AnyObject) {
        let pasteBoard = UIPasteboard.general.strings
        if  ((addressTxtField.text?.isEmpty) != nil){
            addressTxtField?.text = ""
        }
        addressTxtField?.text = pasteBoard?.last
        validator.validate(delegate: self as! ValidationDelegate)
    }

    @IBAction func qrCodeBtnTapped(sender: AnyObject) {
        self.scanViewController.delegate = self
        self.navigationController?.present(self.scanViewController , animated: true, completion: nil)
    }
    
    @IBAction func ffSwitched(sender: UISwitch) {
        setFeeForSelectedSwitchAndTurnOffSwitchesExcept(switched: sender)
    }
    
    @IBAction func hhSwitched(sender: UISwitch) {
        setFeeForSelectedSwitchAndTurnOffSwitchesExcept(switched: sender)
    }
    
    @IBAction func hSwitched(sender: UISwitch) {
        setFeeForSelectedSwitchAndTurnOffSwitchesExcept(switched: sender)
    }
        
    @IBAction func sliderChanged(sender: UISlider) {
        let intValue = Int(sender.value)
        self.amountSatTxtField.text = String(intValue)
        self.amountFiatTxtField.text = self.getFiatString(bySatoshi: intValue, withCode: false)
        self.changeValidatableFieldToDefault(validateField: self.amountSatTxtField, errorLbl: self.amountErrorLabel!)
        self.changeValidatableFieldToDefault(validateField: self.amountFiatTxtField, errorLbl: self.amountErrorLabel!)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.selectorAmountChanged), object: self)
    }
    
    @IBAction func acceptTxBtnTapped(sender: AnyObject) {
        validator.validate(delegate: self as! ValidationDelegate)
        textFieldShouldReturn(textField: self.amountSatTxtField)
        
        let alertController = UIAlertController(title: "Send Transaction Error", message: "Error not all properties are valid", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:{ UIAlertAction in
            //b|
        })
        alertController.addAction(cancelAction)
        
        if (addressValid && amountValid){
            let reasonString = "Authenticate yourself \nYou want to send \(self.amountSatTxtField!.text!)(\(self.amountFiatTxtField!.text!)) \nTo address \(self.addressTxtField!.text!)\nWith miners fee \(self.feeValSatLbl!.text!)(\(self.feeValFiatLbl!.text!))"
            self.authenticateUser(reasonString: reasonString, succes: { auth in
                if auth {
                    self.counterTx = self.counterTx + 1
                    print("Counter equals \(self.counterTx)")
                    self.transactionProtocol?.createTransaction()
                    self.transactionProtocol?.signTransaction()
                    self.transactionProtocol?.sendTransaction(succes: { response in
                        alertController.title = "Transaction sended"
                        alertController.message = "Authentication is successfull Transaction Sended"
                        self.present(alertController, animated: true, completion: nil)
                        //self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            })
        } else {
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    //MARK:
}
