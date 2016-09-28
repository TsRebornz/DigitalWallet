import Foundation
import Alamofire

public protocol TransactionProtocol : class {
    
    func createTransaction()
    func signTransaction()
    func sendTransaction( succes : @escaping ( _ response : AnyObject ) -> Void )
    func changeSendAddress(newAddress : String)
}

public protocol MinersFeeProtocol : class {
    func calculateMinersFee() -> Int
    func updateMinersFeeWithFee(newFeeRate : Int) -> Int
    func updateMinersFeeWithAmount(newAmount : Int) -> Int
}

public class Transaction : NSObject, TransactionProtocol, MinersFeeProtocol {
    //TODO: This variable must be calculated dynamically
    private let default_max_fee : Int = 100000
    private var sendAddress : String
    private let fee : Int
    private let amount : Int
    private let brkey : BRKey
    public let address : AnyObject?
    public var txData : TxData?
    public var transaction : BRTransaction?
    
    // MARK: - Initializers
    public init(address : Address , brkey: BRKey, sendAddress : String , fee : Int , amount : Int  ) {
        self.sendAddress = sendAddress
        self.fee = fee
        self.amount = amount
        self.brkey = brkey
        self.address = address
    }
    // MARK:
    
    //MARK: - MinersFeeProtocol
    public func calculateMinersFee() -> Int {
        if( nil == self.txData ){
            self.prepareMetaDataForTx()
        }
        return self.txData!.calculateMinersFee()
    }
    
    public func updateMinersFeeWithFee(newFeeRate : Int) -> Int {
        guard let v_txData = self.txData else {
            NSException(name: NSExceptionName(rawValue: "Transaction.calculateMinersFee"), reason: "MinersFee", userInfo: nil).raise()
            return 0
        }
        v_txData.updateFee(newFee: newFeeRate)
        let miners_fee = v_txData.calculateMinersFee()
        return miners_fee
    }
    
    public func updateMinersFeeWithAmount(newAmount : Int) -> Int {
        guard let v_address : Address = self.address as? Address,
              let v_txData : TxData = self.txData
        else {
            return 0
        }
        
        let optimizedInputs = TXService.optimizeInputsByAmount(inputs: v_address.txsrefs!, ui_amount: newAmount )
        v_txData.changeInputs(newInputs: optimizedInputs)
        v_txData.updateAmounts(amounts: [newAmount])
        let miners_fee = v_txData.calculateMinersFee()
        return miners_fee
    }
    //MARK:
    
    //MARK: - TransactionProtocol
    public func createTransaction(){
        guard let t_txdata = self.txData else {
            NSException(name: NSExceptionName(rawValue: "TransactionCreateExceiption"), reason: "TxData is nil", userInfo: nil).raise()
            return
        }
        self.calculateVariablesForMetaData()
        guard let t_output = t_txdata.output else {
            NSException(name: NSExceptionName(rawValue: "TransactionCreateExceiption"), reason: "OutPut in TxData is nil", userInfo: nil).raise()
            return
        }
        let transaction : BRTransaction = BRTransaction(inputHashes: t_txdata.input.hashes,
                                            inputIndexes: t_txdata.input.indexes as [NSNumber]!,
                                            inputScripts: t_txdata.input.scripts,
                                            outputAddresses: t_output.addresses,
                                            outputAmounts: t_output.amounts as [NSNumber]!,
                                            isTesnet: self.brkey.isTestnetValue())
        
        self.transaction = transaction
    }
    
    public func signTransaction(){
        guard let t_tx = self.transaction else {
            NSException(name: NSExceptionName(rawValue: "TransactionSignExceiption"), reason: "Transaction is nil, maybe forgotten to create it?", userInfo: nil).raise()
            return
        }
        t_tx.sign(withPrivateKeys: [brkey.privateKey!])
    }
    
    public func sendTransaction( succes : @escaping ( _ response : AnyObject ) -> Void ) {
        guard let txRawDataString : String = self.transaction?.getRawTxDataStr() else {
            NSException(name: NSExceptionName(rawValue: "TransactionCreateException"), reason: "Can not get raw tx data", userInfo: nil ).raise()
            return
        }
        let parameters = ["tx" : txRawDataString as Any ]
        let requestStr = brkey.isTestnetValue() ? BlockCypherApi.RequestType.TestNetPushTx.rawValue : BlockCypherApi.RequestType.MainNetPushTx.rawValue
        let request = Alamofire.request(requestStr, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
        
        request.validate()
        var txResponse: PushTxResponse? = nil
        request.responseJSON(completionHandler: { response in
            guard let jsonResp = response.result.value as? [String : AnyObject] else {
                print("BadResponse from Post transaction request \(response)")
                return
            }
            txResponse = PushTxResponse(json: jsonResp)!
            succes( txResponse as! AnyObject )
        })
    }
    //MARK:
    
    public func prepareMetaDataForTx() {
        //Initialization
        let otimizedTsRefs : [TxRef] = TXService.optimizeInputsByAmount(inputs: (self.address as! Address).txsrefs! , ui_amount: self.amount )
        self.createMetaData(optimizedRefs: otimizedTsRefs, brkey: self.brkey, sendAddresses: [self.sendAddress], amounts: [self.amount], feeValue: self.fee)
    }
    
    //Easy to test
    func createMetaData(optimizedRefs: [TxRef], brkey : BRKey, sendAddresses : [String], amounts : [Int], feeValue : Int  ){
        self.txData = TxData(txrefs: optimizedRefs, brkey: brkey, sendAddresses: sendAddresses, amounts: amounts , selectedFee: feeValue)
    }
    
    public func calculateVariablesForMetaData() {
        guard let t_txdata = self.txData else {
            NSException(name: NSExceptionName(rawValue: "TransactionCreateException"), reason: "TxData is nil", userInfo: nil).raise()
            return
        }
        let miners_fee = t_txdata.calculateMinersFee()
        t_txdata.createOuputModelByInputAndAmount(minersFee: miners_fee)
    }
    
    
    public func changeSendAddress(newAddress : String) {
        self.sendAddress = newAddress
        self.txData?.sendAddresses = [newAddress]
    }
}
