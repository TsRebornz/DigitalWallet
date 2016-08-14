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

class TxData {
    //User Input Varaibles
    let brkey : BRKey
    let sendAddress : String
    var input : InputModel
    let amount : Int
    let balance : Int
    let fee : Int
    
    //Calculatable variables
    var output : OutputModel?
    var miners_fee : Int?
    
    
    internal init(txrefs : [TxRef], balance : UInt64 , brkey : BRKey ,  sendAddress : String, amount : Int , selectedFee: Int  ){
        
        self.brkey = brkey
        self.sendAddress = sendAddress
        self.amount = amount
        self.balance = Int( balance )
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
