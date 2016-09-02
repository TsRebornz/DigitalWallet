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
    var fee : Int
    
    //Calculatable variables
    var output : OutputModel?
    
    public init?(txrefs : [TxRef], brkey : BRKey,  sendAddresses : [String], amounts : [Int], selectedFee: Int) {
        guard sendAddresses.count == amounts.count else {
            NSException(name: "TxDataInitException", reason: "Sendaddresse count must equal amounts count", userInfo: nil).raise()
            return nil
        }
        
        self.brkey = brkey
        self.sendAddresses = sendAddresses
        self.amounts = amounts        
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
    
    func changeInputs(newInputs : [TxRef]){
        var hashes = [String]()
        var indexes = [Int]()
        var scripts = [String]()
        var values = [Int]()
        
        for utxo in newInputs {
            hashes.append(utxo.tx_hash!)
            indexes.append( Int(utxo.tx_output_n!) )
            scripts.append(utxo.script!)
            values.append( Int(utxo.value!) )
        }
        self.input = InputModel(hashes: hashes, indexes: indexes, scripts: scripts, values: values)
    }
    
    func updateFee(newFee : Int) {
        self.fee = newFee
    }
    
    func calculateMinersFee() -> Int {
        let inputsCount = self.input.scripts.count
        let outputsCount = self.sendAddresses.count

        let miners_fee = TXService.calculateMinersFee(inputsCount, outputsCount: outputsCount, fee: self.fee)
        return miners_fee
    }
    
    func createOuputModelByInputAndAmount(minersFee : Int) {
        var adressesArr = [String]()
        adressesArr += self.sendAddresses
        var amountsArr = [Int]()
        amountsArr += self.amounts
        let allInputsVallue = self.input.values.reduce(0, combine: +)
        let sumAmmounts = amountsArr.reduce(0, combine: +)
        let fee_yourself = allInputsVallue - sumAmmounts - minersFee
        let selfAddress = brkey.address
        adressesArr += [selfAddress!]
        amountsArr += [fee_yourself]
        
        self.output = OutputModel(addresses: adressesArr, amounts: amountsArr)
    }
}
