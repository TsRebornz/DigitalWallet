import Foundation

class TXService {
    
    static let default_max_fee : Int = 100000
    
    static let averageInputCost : Int = 146
    static let averageOuputCost : Int = 33
    
    class func calculateMinersFee(inputsCount : Int, outputsCount : Int, fee : Int) -> Int {
        let aprTxBytes : Int = TXService.aproximateSizeInBytes(inputsCount, outputsCount: outputsCount, isNeedFee: true)
        return aprTxBytes * fee
    }
    
    class func choseRightInputsModel() {
        
    }
    
    private class func aproximateSizeInBytes(inputsCount : Int, outputsCount : Int, isNeedFee : Bool) -> Int {
        let outPutToSelf = 1
        return averageInputCost * inputsCount + averageOuputCost * (outputsCount + ( isNeedFee ? outPutToSelf : 0 ) ) + 10
    }
    
    class func optimizeInputsByAmount(inputs: [TxRef], ui_amount : Int ) -> [TxRef]{
        // We know what balance > ui_amount
        guard inputs.count > 1 else{
            return inputs
        }
        
        var optimized_txrefs = [TxRef]()
        var sorted_tx_refs = inputs.sort { $0.value < $1.value }
        let amountAndFee = ui_amount + default_max_fee
        var utxo_sum_val : Int = 0
        
        for (index, tx_ref) in sorted_tx_refs.enumerate() {
            utxo_sum_val += tx_ref.value!
            if (index != sorted_tx_refs.count - 1){
                if ( utxo_sum_val > amountAndFee ) {                    
                    optimized_txrefs = createArrayFromArrayAndIndex(sorted_tx_refs, index: index)
                    break
                } else if((amountAndFee - utxo_sum_val) <= (sorted_tx_refs[(index+1)].value! - sorted_tx_refs[index].value!) ) {
                    // Swap tx_refs
                    let tempValue = sorted_tx_refs[index]
                    sorted_tx_refs[index] = sorted_tx_refs[index+1]
                    sorted_tx_refs[index+1] = tempValue
                    optimized_txrefs = createArrayFromArrayAndIndex(sorted_tx_refs, index: index)
                    break
                }
            }else {
                return inputs
            }
        }
        return optimized_txrefs
    }
    
    class func createArrayFromArrayAndIndex(inputArray: [TxRef], index : Int) -> [TxRef]{
        let optimized_txrefs = Array(inputArray[0..<index+1])
        return optimized_txrefs
    }
}



