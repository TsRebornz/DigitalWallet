import Foundation

public class Transaction : NSObject {
    
    //TODO: This variable must be calculated dynamicallyy
    private let default_max_fee : Int = 100000
    
    private let sendAddress : String
    private let fee : Int
    private let amount : Int
    
    private let testnet : Bool
    
    private let brkey : BRKey
    
    public var address : AnyObject?
    
    private var transaction : BRTransaction?
    
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
        self.address = Address()
        
        self.transaction = nil
        self.txData = nil
        
    }
    
    public func getAddress() {
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(addressUpdated), name: "blockcypher.api.addressupdated", object: nil)
        if (nil == (self.address as! Address).address ){
            self.getAddressFromApi()
            
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    public func getAddressFromApi() {
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
                //NSNotificationCenter.defaultCenter().postNotificationName("blockcypher.api.addressupdated", object: self.address)
            })
        }
    }
    
    public func addressUpdated(){
        NSException(name: "Transaction.getAddres", reason: "AddressUpdated", userInfo: nil).raise()
    }
    
    
    
    //Allow to use minimal inputs in forming transaction
    //Version 1.0
    func optimizeInputsAccordingToAmount(inputs: [TxRef]) -> [TxRef] {
        var optimized_txrefs = [TxRef]()
        if nil != (self.address as! Address).address  {
            let t_address : Address =  self.address as! Address
            //Sort txRefs by value
            let ui_amount = self.amount
            let sorted_txrefs = inputs.sort( { s1, s2 in return s1.value < s2.value } )
            var utxo_sum_val : Int = 0
            for txref in sorted_txrefs {
                utxo_sum_val += txref.value!
                optimized_txrefs += [txref]
                let fee = utxo_sum_val - ui_amount
                guard utxo_sum_val > ui_amount && fee > default_max_fee else {
                    return optimized_txrefs
                }
            }
        }
        return optimized_txrefs
    }
    
    //Version 2.0
    func optimizeInputsByAmount(inputs: [TxRef], ui_amount : Int ) -> [TxRef]{
        // We know what balance > ui_amount
        var optimized_txrefs = [TxRef]()        
        var sorted_tx_refs = inputs.sort( { s1, s2 in return s1.value < s2.value } )
        let amountAndFee = ui_amount + default_max_fee
        var utxo_sum_val : Int = 0
        for (index, tx_ref) in sorted_tx_refs.enumerate() {
            utxo_sum_val += tx_ref.value!            
            if ( utxo_sum_val > amountAndFee ){
                optimized_txrefs = createArrayFromArrayAndIndex(sorted_tx_refs, index: index)
                break
            }else if((amountAndFee - utxo_sum_val) < (sorted_tx_refs[(index+1)].value! - sorted_tx_refs[index].value!) ) {
                // Swap tx_refs
                let tempValue = sorted_tx_refs[index]
                sorted_tx_refs[index] = sorted_tx_refs[index+1]
                sorted_tx_refs[index+1] = tempValue
                optimized_txrefs = createArrayFromArrayAndIndex(sorted_tx_refs, index: index)
                break
            }
            
        }
        return optimized_txrefs
    }
    
    func createArrayFromArrayAndIndex(inputArray: [TxRef], index : Int) -> [TxRef]{
        let optimized_txrefs = Array(inputArray[0..<index])
        return optimized_txrefs
    }
    

//    for (index, value) in shoppingList.enumerate() {
//    print("Item \(index + 1): \(value)")
//    }
   
    //HINT: Dont forget to optimize inputs optimizeInputsAccordingToAmount
    func prepareMetaDataForTx(){
        //Initialization        
        let otimizedTsRefs : [TxRef] = optimizeInputsByAmount((self.address as! Address).txsrefs! , ui_amount: self.amount )
        let addressModel : Address = self.address as! Address
        guard let t_balance = addressModel.balance else {
            return
        }
        self.txData = TxData(txrefs: otimizedTsRefs, balance: UInt64(Int(t_balance)) , brkey: self.brkey, sendAddress: self.sendAddress, amount: self.amount , selectedFee: self.fee)
    }
    
    
    func createTransaction(){
//        self.transaction = BRTransaction(inputHashes: self.txData?.input.ha,
//                                            inputIndexes: TxData.inputIndexes,
//                                            inputScripts: TxData.inputScripts,
//                                            outputAddresses: TxData.outputScripts,
//                                            outputAmounts: TxData.outputAmounts,
//                                            isTesnet: self.testnet)
    }
    
    func sendTransaction(){
        
    }
}
