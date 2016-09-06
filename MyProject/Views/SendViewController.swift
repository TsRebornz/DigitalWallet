import Foundation
import UIKit
import SwiftValidator

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
    @IBOutlet weak var sliderMaxValLabl : UILabel!
    
    @IBOutlet weak var amountErrorLabel: UILabel!
    @IBOutlet weak var amountTxtField: UITextField!    
    
    @IBOutlet weak var feeValLbl : UILabel!
    
    let validator = Validator()
    
    //It this values will be nil all view will fuck up
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
    var allValid : Bool = false
    
    //FIXME:Extract to singleton
    var GlobalUserInitiatedQueue: dispatch_queue_t {
        let qualityOfServiceClass = QOS_CLASS_USER_INITIATED
        return dispatch_get_global_queue(qualityOfServiceClass, 0)
    }
    
//    init() {
//        super.init(nibName: nil, bundle: nil)
//    }
    
//    required public init?(coder aDecoder: NSCoder) {
//        super.init(nibName: nil, bundle: nil)
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //UISwitchLogic
        switchArr += [ffSwitch,hhSwitch,hSwitch]
        switchDictionary = [ self.ffSwitch! : self.ffLbl! , self.hhSwitch! : self.hhLbl! , self.hSwitch! : self.hLbl! ]
        
        self.prepareAndLoadViewData()
        
        //Notifications
        //Need to know when feeData is loaded
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(feeDataChanged), name: selectorFeeChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(amountDataChanged), name: selectorAmountChanged, object: nil)
        
        //Valiadtion in privateKeyTextField
        validator.registerField(addressTxtField, errorLabel: addressErrorLabel, rules: [RequiredRule(), AddressRule() ])
        validator.registerField(amountTxtField, errorLabel: amountErrorLabel, rules: [RequiredRule(), DigitRule() ])
    }
    
    func prepareAndLoadViewData(){
        self.loadSliderData()
        self.updateFeeData()
        self.loadFeeData()
        self.selectedFeeRate = 0
        self.feeValLbl.text = "0"
        
        addressTxtField.layer.cornerRadius = 5
        addressTxtField.delegate = self
        amountTxtField.delegate = self        
    }
    
    override public func viewWillAppear(animated: Bool) {
        self.scanViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ScanViewController") as! ScanViewController
    }
    
    func createTxDataWithDefaultParameters(){
        //Needs only for initialization
        let defaultFee = 0
        let sendAddress = self.testAddress
        let validKey = self.key!
        let amountString = self.amountTxtField.text!
        let amount = Int(amountString)!
        let testnet = validKey.isTestnetValue()
        let transaction : Transaction = Transaction(address: self.address!, brkey: validKey, sendAddress: sendAddress, fee: defaultFee , amount: amount, testnet: testnet)
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
//                NSNotificationCenter.defaultCenter().addObserver(self.transactionProtocol., selector: #selector(transactionSended), name: "transaction.send.response", object: nil)
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
        self.sliderMaxValLabl.text = String(balance)
        let defaultVal = Float(balance/10)
        self.amountSlider.setValue( defaultVal , animated: true)
        self.amountTxtField.text = "\(Int(defaultVal))"
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
        if(textField == self.amountTxtField) {
            validator.validateField(textField){ error in
                if error == nil {
                    //Field validation was successful
                    //let amount : Int = Int(textField.text!)!
                    self.changeValidatableFieldToDefault(self.amountTxtField, errorLbl: self.amountErrorLabel)
                    NSNotificationCenter.defaultCenter().postNotificationName(self.selectorFeeChanged, object: self, userInfo: nil)
                    self.allValid = true
                    
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
    //MARK:
    
    func changeValidatableFieldToDefault(validateField: UITextField, errorLbl : UILabel){
        validateField.layer.borderColor = UIColor.greenColor().CGColor
        validateField.layer.borderWidth = 1.0
        errorLbl.hidden = true
    }
    
    //MARK:Validation
    public func validationSuccessful(){
        self.allValid = true
        self.changeValidatableFieldToDefault(self.addressTxtField, errorLbl: self.addressErrorLabel!)
        self.transactionProtocol?.changeSendAddress(self.addressTxtField.text!)
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
    //MARK:
    
    //MARK:Notifications
    func feeDataChanged() {
        let miners_fee : Int = (self.minersFeeProtocol!.updateMinersFeeWithFee(self.selectedFeeRate))
        self.feeValLbl?.text = "\(miners_fee)"
    }
    
    func amountDataChanged() {
        let strAmount : String = self.amountTxtField.text!
        let miners_fee : Int = (self.minersFeeProtocol!.updateMinersFeeWithAmount(Int(strAmount)!))
        self.feeValLbl?.text = "\(miners_fee)"
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
        self.amountTxtField.text = String(intValue)
        self.changeValidatableFieldToDefault(self.amountTxtField, errorLbl: self.amountErrorLabel!)
        NSNotificationCenter.defaultCenter().postNotificationName(self.selectorAmountChanged, object: self, userInfo: nil)
    }
    
    func transactionSended(){
        
        
        
    }
        
    @IBAction func acceptTxBtnTapped(sender: AnyObject) {
        validator.validate(self)
        textFieldShouldReturn(self.amountTxtField)
        //For HamsterPic
        //var alertController = UIAlertController(nibName: <#T##String?#>, bundle: <#T##NSBundle?#>)
        var title = "Send Transaction Error"
        var message = "Error not all properties are valid"
        var uiAlertActions : [UIAlertAction] = [UIAlertAction]()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:{ UIAlertAction in
                //b|
            })
        uiAlertActions.append(cancelAction)
        
        if (allValid){
            title = "Send Transaction"
            message = "You want to send \(self.amountTxtField!.text!) satoshi. To address \(self.addressTxtField!.text!). With miners fee \(self.feeValLbl!.text!)"
            let okAction = UIAlertAction(title: "Send", style: UIAlertActionStyle.Default, handler: { UIAlertAction in
                //Progress bar
                self.transactionProtocol?.createTransaction()
                self.transactionProtocol?.signTransaction()
                self.transactionProtocol?.sendTransaction({ response in
                   
                    //Send data about Transaction to viewControllers
                    //Throw back to previus screen or transtion screen and save sended transaction to coreData
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            })
            uiAlertActions.append(okAction)
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        for action in uiAlertActions {
            alertController.addAction(action)
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    
    }
    //MARK:
    
}