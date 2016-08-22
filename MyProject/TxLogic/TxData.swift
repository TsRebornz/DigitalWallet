import Foundation

//MetaData for forming Transaction

struct OutputModel {
    let addresses : [String]
    let amounts : [Int]
}

struct InputModel {
    let hashes : [String]
    let indexes : [Int]
    let scripts : [String]
    let values : [Int]
}

public class TxData {
    //User Input Varaibles
    let brkey : BRKey
    let sendAddresses : [String]
    var input : InputModel
    let amounts : [Int]
    let balance : Int
    let fee : Int
    
    //Calculatable variables
    var output : OutputModel?
    var miners_fee : Int?
    
    
    public init(txrefs : [TxRef], balance : Int , brkey : BRKey ,  sendAddresses : [String], amounts : [Int] , selectedFee: Int  ){
        
        self.brkey = brkey
        self.sendAddresses = sendAddresses
        self.amounts = amounts
        self.balance = balance
        self.fee = selectedFee
        
        var hashes = [String]()
        var indexes = [Int]()
        var scripts = [String]()
        var values = [Int]()
        
        for utxo in txrefs {
            hashes.append(utxo.tx_hash!)
            indexes.append( Int(utxo.tx_output_n!) )
            scripts.append(utxo.script!)
            values.append( Int(utxo.value!) )
        }
        
        self.input = InputModel(hashes: hashes, indexes: indexes, scripts: scripts, values: values)
            
        self.output = nil
    }
    
    // Initialize
    // OpitmizeInputs
    // CalculateVariables
        
    func optimizeInputs(){
        
    }
    
    func calculateVariables(){
        self.output = createOuputModelByInputAndAmount()
        let inputsCount = self.input.scripts.count
        let outputsCount = self.output?.addresses.count

        self.miners_fee = TXService.calculateMinersFee(inputsCount, outputsCount: outputsCount!, fee: self.fee)
    }    
    
    func createOuputModelByInputAndAmount() -> OutputModel {
        
        
        return OutputModel(addresses: ["yreqi"], amounts: [1])
    }
    
}
