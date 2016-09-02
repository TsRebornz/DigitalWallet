import Foundation

public protocol TransactionProtocol : class {
    func prepareMetaDataForTx()
    func calculateVariablesForMetaData()
    func createSignAndSendTransaction()
}

public protocol MinersFeeProtocol : class {
    func calculateMinersFee() -> Int
    func calculateMinersFeeWithFee(newFeeRate : Int) -> Int
    func calculateMinersFeeWithAmount(newAmount : Int) -> Int
}

public class Transaction : NSObject, TransactionProtocol, MinersFeeProtocol {
    
    //TODO: This variable must be calculated dynamicallyy
    private let default_max_fee : Int = 100000
    
    private let sendAddress : String
    private let fee : Int
    private let amount : Int
    
    private let testnet : Bool
    
    private let brkey : BRKey
    
    public let address : AnyObject?
    
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

    // MARK: - Initializers
    public init(address : Address , brkey: BRKey, sendAddress : String , fee : Int , amount : Int , testnet : Bool ) {
        self.sendAddress = sendAddress
        self.fee = fee
        self.amount = amount
        self.testnet = testnet
        self.brkey = brkey
        self.address = address
    }
    
    public init(brkey: BRKey, sendAddress : String , fee : Int , amount : Int , testnet : Bool ) {
        self.sendAddress = sendAddress
        self.fee = fee
        self.amount = amount
        self.testnet = testnet
        self.brkey = brkey
        self.address = Address()
    }
    // MARK:
    public func addressUpdated(){
        NSException(name: "Transaction.getAddres", reason: "AddressUpdated", userInfo: nil).raise()
    }
    
    public func prepareMetaDataForTx() {
        //Initialization
        let otimizedTsRefs : [TxRef] = TXService.optimizeInputsByAmount((self.address as! Address).txsrefs! , ui_amount: self.amount )
        self.createMetaData(otimizedTsRefs, brkey: self.brkey, sendAddresses: [self.sendAddress], amounts: [self.amount], feeValue: self.fee)
    }
    
    public func calculateMinersFee() -> Int {
        guard let valid_txData = self.txData else {
            return 0
        }
        return valid_txData.calculateMiners_fee()
    }
    
    public func calculateMinersFeeWithFee(newFeeRate : Int) -> Int {
        guard let v_txData = self.txData else {
            NSException(name: "Transaction.calculateMinersFee", reason: "MinersFee", userInfo: nil).raise()
            return 0
        }
        v_txData.updateFee(newFeeRate)
        let miners_fee = v_txData.calculateMiners_fee()
        return miners_fee
    }
    
    public func calculateMinersFeeWithAmount(newAmount : Int) -> Int {
        guard let v_address : Address = self.address as? Address,
              let v_txData : TxData = self.txData
        else {
            return 0
        }
        
        let optimizedInputs = TXService.optimizeInputsByAmount(v_address.txsrefs!, ui_amount: newAmount )
        v_txData.changeInputs(optimizedInputs)
        let miners_fee = v_txData.calculateMiners_fee()
        return miners_fee
    }
            
    public func calculateVariablesForMetaData() {
        guard let t_txdata = self.txData else {
            NSException(name: "TransactionCreateExceiption", reason: "TxData is nil", userInfo: nil).raise()
            return
        }
        let miners_fee = t_txdata.calculateMiners_fee()
        t_txdata.createOuputModelByInputAndAmount(miners_fee)
    }
    
    //Easy to test
    func createMetaData(optimizedRefs: [TxRef], brkey : BRKey, sendAddresses : [String], amounts : [Int], feeValue : Int  ){
        self.txData = TxData(txrefs: optimizedRefs, brkey: brkey, sendAddresses: sendAddresses, amounts: amounts , selectedFee: feeValue)
    }
    
    public func createSignAndSendTransaction(){
        
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
        let transaction : BRTransaction = BRTransaction(inputHashes: t_txdata.input.hashes,
                                            inputIndexes: t_txdata.input.indexes,
                                            inputScripts: t_txdata.input.scripts,
                                            outputAddresses: t_output.addresses,
                                            outputAmounts: t_output.amounts,
                                            isTesnet: self.testnet)
        
        self.transaction = transaction
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
