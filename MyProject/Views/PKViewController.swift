import Foundation
import UIKit

//extension PKViewController : ValidationDelegate {
//    
//}

public class PKViewController : UIViewController, UITextFieldDelegate, ValidationDelegate, ScanViewControllerDelegate  {
    
    @IBOutlet weak var privateKeyTextField: UITextField!
    @IBOutlet weak var prkErrorLbl : UILabel!
    @IBOutlet weak var nextBtn : UIButton!
    @IBOutlet weak var testNetSwitch : UISwitch!
    
    //FIXME: Validator HERE!
    let validator = Validator()
    var testnet: Bool = false
    var scanViewController : ScanViewController!
    var key : BRKey?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        testnet = testNetSwitch.isOn
        nextBtn.isEnabled = false
        privateKeyTextField.layer.cornerRadius = 5
        privateKeyTextField.delegate = self
                
        //Valiadtion in privateKeyTextField
        validator.registerField(field: privateKeyTextField, errorLabel: prkErrorLbl, rules: [RequiredRule(), PKBase58() ])
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        self.scanViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - ValidationDelegate methods
    //FIXME: Validator HERE!
    public func validationSuccessful() {
        nextBtn.isEnabled = true
        privateKeyTextField.layer.borderColor = UIColor.green.cgColor
        privateKeyTextField.layer.borderWidth = 1.0
        prkErrorLbl.isHidden = true
        self.checkWifFormatAndDisableTestnetSwitch(pk: privateKeyTextField.text!)
    }
    
    func checkWifFormatAndDisableTestnetSwitch(pk: String){
        let wifFormat : WifFormat = BRKey.checkWIFformatPKkey(pk)
        if (wifFormat != WifNot){
            testNetSwitch.isEnabled = false
        }else{
            testNetSwitch.isEnabled = true
        }
    }
    
    public func validationFailed(errors:[(Validatable ,ValidationError)]) {
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.red.cgColor
                field.layer.borderWidth = 1.0
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
            nextBtn.isEnabled = false
        }
    }
    //MARK: -
    
    //MARK: - UITextFieldDelegate
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        //FIXME: Validator HERE!
        validator.validate(delegate: self)
    }
    //MARK: -
    
    //MARK: - ScanViewControllerDelegate
    func DelegateScanViewController(controller: ScanViewController, dataFromQrCode : String?){
        guard let t_dataQrCode = dataFromQrCode else {return}
        self.privateKeyTextField.text = t_dataQrCode
        //FIXME: Validator HERE!
        validator.validate(delegate: self)
    }
        
    //MARK: -
    
    //MARK: - Actions
    @IBAction func qrCodeBrnTapped(sender: AnyObject) {
        self.scanViewController.delegate = self
        self.navigationController?.present(self.scanViewController , animated: true, completion: nil)
    }
    
    @IBAction func testNetSwitchChanged(sender: AnyObject) {
        self.testnet = (sender as! UISwitch).isOn
    }
    
    @IBAction func insertDataFromPasteBoard() {
        let pasteBoard = UIPasteboard.general.strings
        privateKeyTextField?.text = pasteBoard?.last
        //FIXME: Validator HERE!
        //validator.validate(self)
    }
    //MARK: -
                
    public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destination as! UINavigationController
            if (segue.identifier == "PKSegue"){
                let inspectViewController = navigationController.topViewController as! InspectViewController
                
                let key = BRKey(privateKey: privateKeyTextField.text!, testnet: self.testnet)
                inspectViewController.key = key
            }
    }
}
