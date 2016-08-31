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
    
    public var transaction : BRTransaction?
    
    public var txData : TxData?
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(addressUpdated), name: "blockcypher.api.addressupdated", object: nil)
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
                NSNotificationCenter.defaultCenter().postNotificationName("blockcypher.api.addressupdated", object: self.address)
            })
        }
    }
    
    public func addressUpdated(){
        NSException(name: "Transaction.getAddres", reason: "AddressUpdated", userInfo: nil).raise()
    }
    
    func prepareMetaDataForTx(){
        //Initialization
        let otimizedTsRefs : [TxRef] = TXService.optimizeInputsByAmount((self.address as! Address).txsrefs! , ui_amount: self.amount )
        guard let addressModel : Address = self.address as? Address else {
            NSException(name: "TransactionPrepareMetaData", reason: "Wrong address data", userInfo: nil).raise()
            return
        }
        self.createMetaData(otimizedTsRefs, brkey: self.brkey, sendAddresses: [self.sendAddress], amounts: [self.amount], feeValue: self.fee)
    }
    
    func calculateVariablesForMetaData() {
        guard let t_txdata = self.txData else {
            NSException(name: "TransactionCreateExceiption", reason: "TxData is nil", userInfo: nil).raise()
            return
        }
        let miners_fee = t_txdata.calculateMiners_fee()
        t_txdata.createOuputModelByInputAndAmount(miners_fee)
    }
    
    //Version 2.0
//    func optimizeInputsByAmount(inputs: [TxRef], ui_amount : Int ) -> [TxRef]{
//        // We know what balance > ui_amount
//        guard inputs.count > 1 else{
//            return inputs
//        }
//        
//        var optimized_txrefs = [TxRef]()        
//        var sorted_tx_refs = inputs.sort { $0.value < $1.value }
//        let amountAndFee = ui_amount + default_max_fee
//        var utxo_sum_val : Int = 0
//        
//        for (index, tx_ref) in sorted_tx_refs.enumerate() {
//            utxo_sum_val += tx_ref.value!            
//            if ( utxo_sum_val > amountAndFee ) {
//                //optimized_txrefs = Array(sorted_tx_refs[0...index])
//                optimized_txrefs = createArrayFromArrayAndIndex(sorted_tx_refs, index: index)
//                break
//            } else if((amountAndFee - utxo_sum_val) < (sorted_tx_refs[(index+1)].value! - sorted_tx_refs[index].value!) ) {
//                // Swap tx_refs
//                let tempValue = sorted_tx_refs[index]
//                sorted_tx_refs[index] = sorted_tx_refs[index+1]
//                sorted_tx_refs[index+1] = tempValue
//                optimized_txrefs = createArrayFromArrayAndIndex(sorted_tx_refs, index: index)
//                break
//            }
//            
//        }
//        return optimized_txrefs
//    }
    
//    func createArrayFromArrayAndIndex(inputArray: [TxRef], index : Int) -> [TxRef]{
//        let optimized_txrefs = Array(inputArray[0..<index+1])
//        return optimized_txrefs
//    }
    
    //Easy to test
    func createMetaData(optimizedRefs: [TxRef], brkey : BRKey, sendAddresses : [String], amounts : [Int], feeValue : Int  ){
        self.txData = TxData(txrefs: optimizedRefs, brkey: brkey, sendAddresses: sendAddresses, amounts: amounts , selectedFee: feeValue)
    }
    
    
    
    func createTransaction(){
        guard let t_txdata = self.txData else {
            NSException(name: "TransactionCreateExceiption", reason: "TxData is nil", userInfo: nil).raise()
            return
        }
        guard let t_output = t_txdata.output else {
            NSException(name: "TransactionCreateExceiption", reason: "OutPut in TxData is nil", userInfo: nil).raise()
            return
        }
        self.transaction = BRTransaction(inputHashes: t_txdata.input.hashes,
                                            inputIndexes: t_txdata.input.indexes,
                                            inputScripts: t_txdata.input.scripts,
                                            outputAddresses: t_output.addresses,
                                            outputAmounts: t_output.amounts,
                                            isTesnet: self.testnet)
    }
    
    func signTransaction(){
        guard let t_tx = self.transaction else {
            NSException(name: "TransactionSignExceiption", reason: "Transaction is nil, maybe forgotten to create it?", userInfo: nil).raise()
            return
        }
        t_tx.signWithPrivateKeys([brkey.privateKey!])
    }
    
    func sendTransaction(){
        
    }
    
}
