import Foundation

public class Transaction : NSObject {
    
    //TODO: This variable must be calculated dynamicallyy
    private let default_max_fee : Int = 100000
    
    private let sendAddress : String
    private let fee : Int
    private let amount : Int
    
    private let testnet : Bool
    
    private let brkey : BRKey
    
    private var address : AnyObject?
    
    private let transaction : BRTransaction?
    
    private var txData : TxData?
    
    var GlobalUserInitiatedQueue: dispatch_queue_t {
        let qualityOfServiceClass = QOS_CLASS_USER_INITIATED
        return dispatch_get_global_queue(qualityOfServiceClass, 0)
    }
    
    var GlobalBackGroundQueue: dispatch_queue_t {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        return dispatch_get_global_queue(qualityOfServiceClass, 0)
    }
    
    public init(brkey: BRKey, sendAddress : String , fee : Int , amount : Int , testnet : Bool ) {
        self.sendAddress = sendAddress
        self.fee = fee
        self.amount = amount
        self.testnet = testnet
        self.brkey = brkey
        
        //Need fill data bellow after initialization
        self.address = nil
        self.transaction = nil
        self.txData = nil
    }
    
    public func getAddress() -> Address {
        if (nil == self.address){
            self.getAddressFromApi()
            let timeout : Int = 60
            var time = 0
            //FIXME: Rewrite this code!
                while(nil == self.address){
                    if (time <= timeout){
                        sleep(2)
                        time += 2
                    }else{
                        NSException(name: "Transaction.getAddres", reason: "Timeout reached", userInfo: nil).raise()
                    }
                    
                }
            return self.address as! Address
        }else{
            return self.address as! Address
        }
    }
    
    private func getAddressFromApi() {
        let parameters = [
            "includeScript" : true,
            "unspentOnly" : true
        ]
        
        let selfAddress = self.brkey.address!
        dispatch_async(GlobalUserInitiatedQueue) {
            BlockCypherApi.getAddress(selfAddress, testnet: self.testnet, parameters: parameters, doAfterRequest: {json in
                guard let t_address = Address(json: json) else {
                    print("\(self.description) Bad answer from BlockCypherApi.getAddress")
                    return
                }
                self.address = t_address
            })
        }
    }
    
    //Allow to use minimal inputs in forming transaction
    func optimizeInputsAccordingToAmount() -> [TxRef] {
        var optimized_txrefs = [TxRef]()
        if self.address is Address {
            let t_address : Address =  self.address as! Address
            //Sort txRefs by value
            let ui_amount = self.amount
            let sorted_txrefs = t_address.txsrefs!.sort( { s1, s2 in return s1.value < s2.value } )
            var utxo_sum_val : Int = 0
            for txref in sorted_txrefs {
                utxo_sum_val += txref.value!
                optimized_txrefs += [txref]
                guard utxo_sum_val > ui_amount && utxo_sum_val - ui_amount > default_max_fee else {
                    return optimized_txrefs
                }
            }
        }
        return optimized_txrefs
    }
   
    //HINT: Dont forget to optimize inputs optimizeInputsAccordingToAmount
    func prepareMetaDataForTx(){
        //Initialization        
        let otimizedTsRefs : [TxRef] = optimizeInputsAccordingToAmount()
        let addressModel : Address = self.address as! Address
        
        self.txData = TxData(txrefs: otimizedTsRefs, balance: addressModel.balance!, brkey: self.brkey, sendAddress: self.sendAddress, amount: self.amount , selectedFee: self.fee)        
    }
}
