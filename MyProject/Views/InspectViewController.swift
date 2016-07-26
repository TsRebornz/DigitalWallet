import Foundation
import UIKit
import Alamofire


public class InspectViewController : UIViewController {
    
    @IBOutlet weak var adressLbl : UILabel?
    
    @IBOutlet weak var balanceLbl : UILabel?
    
    var brkey:BRSwiftKey?
    
    
    var GlobalUserInitiatedQueue: dispatch_queue_t {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        return dispatch_get_global_queue(qualityOfServiceClass, 0)        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        fillData()
    }
    
    
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fillData(){
        if let brk = self.brkey{
                adressLbl?.text = brk.brkey?.address
        }
        
        balanceLbl?.text = "Balance no loaded"
    }
    
    func updateData(balance : Balance){
        balanceLbl?.text = String(balance.final_balance)
    }
    
    func errorLoadingData(){
        //balanceLbl?.text =
    }
    

    
    //1DEP8i3QJCsomS4BSMY2RpU1upv62aGvhD
    func getBalanceByAdress(address:String, testnet: Bool ){
        BlockCypherApi.getBalanceByAddress(address, testnet: testnet,  succes: { (bal:Balance) -> Void in
           self.updateData(bal)
        })
    }
    
    func getFullAddress(address: String, testnet: Bool){
//        let a = 1
        BlockCypherApi.getFullAddress(address, testnet: true, doAfterRequest:{ json in
            for string in json {
                print(string)
            }
        })
    }
    
    
    
    
    
    
    
    
    func alamomoTestFunc(){
            //NSURLRequest
            //Alamofire.request(<#T##URLRequest: URLRequestConvertible##URLRequestConvertible#>)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func check(sender: AnyObject){
        dispatch_async(GlobalUserInitiatedQueue) {
            self.getBalanceByAdress((self.brkey?.brkey?.address)!, testnet: (self.brkey?.bool)!)
            self .getFullAddress((self.brkey?.brkey?.address)!, testnet: (self.brkey?.bool)!)
            
        }
    }
    
}


