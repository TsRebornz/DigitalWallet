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
    
    var address : Address?
    var feeData : Fee?
    
    var GlobalUserInitiatedQueue: dispatch_queue_t {
        let qualityOfServiceClass = QOS_CLASS_USER_INITIATED
        return dispatch_get_global_queue(qualityOfServiceClass, 0)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.updateFeeData()
        self.loadFeeData()
        //load address here
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
    
    //Actions
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func inserBtnTapped(sender: AnyObject) {
        
    }
    
    @IBAction func qrCodeBtnTapped(sender: AnyObject) {
        
    }
    
    @IBAction func acceptTxBtnTapped(sender: AnyObject) {
        
    }
    //End
}