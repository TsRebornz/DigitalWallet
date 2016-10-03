import Foundation
import UIKit
import Alamofire
import CoreImage


public class InspectViewController : UIViewController {
    
    @IBOutlet weak var sendBtn: UIButton?
    
    @IBOutlet weak var adressLbl : UILabel?
    
    @IBOutlet weak var balanceLbl : UILabel?
    
    @IBOutlet weak var qrCodeImageView : UIImageView?
    
    let minBalanceForSending : Int = 50000
    
    let defaultLoadingTime: Int = 60
    
    var address : Address?
    
    var isDataLoading: Bool = false
    
    var key:BRKey!
    
    var qrcodeImage: CIImage!
        
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.sendBtn?.isEnabled = false
        fillData()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        //blah blah blah
        self.updateBalance()
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
                if (self.isDataLoading) {
                    if (!(lbl.text!.contains("..."))) {
                        DispatchQueue.main.async {
                            lbl.text!.append("." as Character)
                        }
                    }else {
                        DispatchQueue.main.async {
                            lbl.text! = text
                        }
                    }
                    sleep(1)
                }
            i += 1
        }
    }
    
    //MARK:QrCode
    func generateQrCodeImage(){
        let dataForQrCode = self.adressLbl?.text
        guard (nil == self.qrcodeImage && "" != dataForQrCode) else {
            return
        }
        
        let data: NSData = (dataForQrCode!.data(using: String.Encoding.isoLatin1, allowLossyConversion: false))! as NSData
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter!.setValue(data, forKey: "inputMessage")
        filter!.setValue("Q", forKey: "inputCorrectionLevel")
        
        self.qrcodeImage = filter!.outputImage
        
        displayQRCodeImage()
    }
    
    func displayQRCodeImage(){
        let scaleX = self.qrCodeImageView!.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = self.qrCodeImageView!.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        self.qrCodeImageView!.image = UIImage(ciImage: transformedImage)
    }
    //MARK:
    
    
    //MARK:Network
    func getAddressModelByAddress(address:String, testnet: Bool ){
        let parameters = [
            "includeScript" : true,
            "unspentOnly" : true
        ]
        
        BlockCypherApi.getAddress(address: address, testnet: testnet, parameters: parameters as [String : AnyObject]?, doAfterRequest: { json in
            self.isDataLoading = false
            guard let t_address = Address(json: json) else {
                return
            }
            self.address = t_address
            self.updateBalance()
            self.unlockSendButton()
        })
    }
    //MARK:
    
    func updateBalance() {
        if ( nil != self.address ){
            balanceLbl?.text = "\(self.address!.balance!) \(getFiatString() )"
        }else{
            balanceLbl?.text = "Balance no loaded"
        }
    }
    
    func unlockSendButton() {
        guard let t_balance : Int = self.address!.balance! as Int? else {
            return
        }
        if (t_balance > self.minBalanceForSending) {
            self.sendBtn?.isEnabled = true
        }
    }
    
    func getFiatString() -> String {        
        let localCurrency : CurrencyPrice? = MPManager.sharedInstance.sendData(byString: MPManager.localCurrency) as! CurrencyPrice?
        let fiatBalanceString = Utilities.getFiatBalanceString(model: localCurrency, satoshi: Int(self.address!.balance!) , withCode: true)
        //Utilities.getFiatBalanceString(localCurrency, satoshi: Int(self.address!.balance!) )
        let fiatString = fiatBalanceString != "" ? "(\(fiatBalanceString) )" : ""
        return fiatString
    }
    
    func fillData(){
        if let v_key = self.key {
            adressLbl?.text = v_key.address
        }
        self.updateBalance()
        self.generateQrCodeImage()
    }
    
    //MARK:IBActions
    @IBAction func cancel(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func check(sender: AnyObject){
        let userInitiatedQueue = GCDManager.sharedInstance.getQueue(byQoS: DispatchQoS.userInitiated)
        let userInteractiveQueue = GCDManager.sharedInstance.getQueue(byQoS: DispatchQoS.userInteractive)
        userInitiatedQueue.async {
            self.isDataLoading = true
            
            userInteractiveQueue.async {
                self.dataLoadingUpdate()
            }
            
            self.getAddressModelByAddress(address: (self.key.address)!, testnet: (self.key.isTestnetValue()))
        }
    }
    //MARK:
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        if (segue.identifier == "SendSegue") {
            let sendViewController = navigationController.topViewController as! SendViewController
            
            guard let t_address = self.address else {
                NSException(name: NSExceptionName(rawValue: "InspectViewController prepareForSegue"), reason: "Address is nil", userInfo: nil).raise()
                return
            }
            sendViewController.address = t_address
            sendViewController.key = self.key
        }
    }
    
}


