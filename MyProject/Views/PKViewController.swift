import Foundation
import UIKit
import SwiftValidator

public class PKViewController : UIViewController, ValidationDelegate, UITextFieldDelegate  {
    
    let validator = Validator()
    
    @IBOutlet weak var privateKeyTextField: UITextField!
    @IBOutlet weak var prkErrorLbl : UILabel!
    @IBOutlet weak var nextBtn : UIButton!
    let maxSymbolPKLength = 64
    
    var submited: Bool = false

    //var privateKey: String = "cSF9RngdtVNaKpbsH6eBgWGm8xFNc3ViRXgZpfQddQxaGe2G4uXJ"
    var privateKey: String = ""
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        nextBtn.enabled = submited
        privateKeyTextField.delegate = self
        //let device: String = UIDevice.currentDevice().model
        
        //Valiadtion in privateKeyTextField
        validator.registerField(privateKeyTextField, errorLabel: prkErrorLbl, rules: [RequiredRule(), PKBase58Rule(),  MaxLengthRule(length : maxSymbolPKLength) ])
    }
    

    // ValidationDelegate methods
    public func validationSuccessful() {
        nextBtn.enabled = true
        privateKeyTextField.layer.borderColor = UIColor.greenColor().CGColor
        privateKeyTextField.layer.borderWidth = 1.0
        prkErrorLbl.hidden = true
    }
    
    public func validationFailed(errors:[(Validatable ,ValidationError)]) {
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.redColor().CGColor
                field.layer.borderWidth = 1.0
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.hidden = false
            nextBtn.enabled = false
        }
    }
    // End
    
    // UITextFieldDelegate begin
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        validator.validate(self)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()        
    }
    //end
    
    @IBAction func insertDataFromPasteBoard() {
        let pasteBoard = UIPasteboard.generalPasteboard().strings
        if  ((privateKeyTextField.text?.isEmpty) != nil){
            privateKeyTextField?.text = ""
        }
        privateKeyTextField?.text = pasteBoard?.last
        validator.validate(self)
    }
    
    func filldata(){
        if ((privateKeyTextField?.text?.isEmpty) != nil){
            privateKeyTextField?.text? = privateKey
        }
    }
    
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
            if (segue.identifier == "PKSegue"){
                let inspectViewController = navigationController.topViewController as! InspectViewController
                
                let brkey = BRSwiftKey.init(privateKey: privateKeyTextField!.text!, testnet: true)
                
                inspectViewController.brkey = brkey
            }
    }
    
}
