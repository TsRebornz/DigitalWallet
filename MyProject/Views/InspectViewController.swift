import Foundation
import UIKit
import Alamofire
import CoreImage


public class InspectViewController : UIViewController {
    
    let defaultLoadingTime: Int = 60
    
    @IBOutlet weak var adressLbl : UILabel?
    
    @IBOutlet weak var balanceLbl : UILabel?
    
    @IBOutlet weak var qrCodeImageView : UIImageView?
    
    var a : AnyObject = 5 as Int
    
    var isDataLoading: Bool = false
    
    var brkey:BRSwiftKey?
    
    var qrcodeImage: CIImage!
    
    
    //MultiThreading shit
    var GlobalUserInitiatedQueue: dispatch_queue_t {
        let qualityOfServiceClass = QOS_CLASS_USER_INITIATED
        return dispatch_get_global_queue(qualityOfServiceClass, 0)        
    }
    
    var GlobalBackGroundQueue: dispatch_queue_t {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        return dispatch_get_global_queue(qualityOfServiceClass, 0)
    }
    
    var GlobalUserInteractiveQueue: dispatch_queue_t {
        let qualityOfServiceClass = QOS_CLASS_USER_INTERACTIVE
        return dispatch_get_global_queue(qualityOfServiceClass, 0)
    }
    //END
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        fillData()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataLoadingUpdate() {
        let text = "Loading"
        self.balanceLbl?.text = text
        let lbl : UILabel = self.balanceLbl!
        
        var i = 0
        while(i<self.defaultLoadingTime) {
                ////TO:DO Rewrite without if(self.isDataLoading)
                if (self.isDataLoading) {
                    if (!(lbl.text!.containsString("..."))) {
                        dispatch_async(dispatch_get_main_queue()) {
                            lbl.text!.append("." as Character)
                        }
                    }else {
                        dispatch_async(dispatch_get_main_queue()) {
                            lbl.text! = text
                        }
                    }
                    sleep(1)
                }
            i += 1
        }
    }
    
    func fillData(){
        if let brk = self.brkey{
                adressLbl?.text = brk.brkey?.address
        }
        self.generateQrCodeImage()
        balanceLbl?.text = "Balance no loaded"
    }
    
    func generateQrCodeImage(){
        let dataForQrCode = self.balanceLbl?.text
        guard (nil == self.qrcodeImage && "" != dataForQrCode) else {
            return
        }
        
        let data: NSData = (dataForQrCode!.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false))!
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter!.setValue(data, forKey: "inputMessage")
        filter!.setValue("Q", forKey: "inputCorrectionLevel")
        
        self.qrcodeImage = filter!.outputImage
        
        displayQRCodeImage()
    }
    
    func displayQRCodeImage(){
        let scaleX = self.qrCodeImageView!.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = self.qrCodeImageView!.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))
        
        self.qrCodeImageView!.image = UIImage(CIImage: transformedImage)
    }
    
    
    
    func updateData(balance : Balance){
        if (!(balanceLbl!.text!.isEmpty)){
            balanceLbl!.text! = ""
        }
        balanceLbl?.text = String(balance.final_balance!)
    }
    
    func errorLoadingData(){
        //balanceLbl?.text =
    }
    
    func getBalanceByAdress(address:String, testnet: Bool ){
        BlockCypherApi.getBalanceByAddress(address, testnet: testnet, parameters: nil,  succes: { (bal:Balance) -> Void in
                self.isDataLoading = false
                self.updateData(bal)
        })
    }
    
    func getFullAddress(address: String, testnet: Bool){
        BlockCypherApi.getAddress(address, testnet: true, parameters: nil, doAfterRequest:{ json in
            //Put create new transaction mechanic here
        })
    }
    
    //IBActions
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func check(sender: AnyObject){
        dispatch_async(GlobalUserInitiatedQueue) {
            self.isDataLoading = true
            
            dispatch_async(self.GlobalUserInteractiveQueue){
                self.dataLoadingUpdate()
            }                        
            
            self.getBalanceByAdress((self.brkey?.brkey?.address)!, testnet: (self.brkey?.bool)!)
            
            //self .getFullAddress((self.brkey?.brkey?.address)!, testnet: (self.brkey?.bool)!)
        }
    }
    //End
    
}


