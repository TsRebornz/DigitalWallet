import Foundation

class TXService {
    
    static let averageInputCost : Int = 146
    static let averageOuputCost : Int = 33
    
    class func calculateMinersFee(inputsCount : Int, outputsCount : Int, fee : Int ) -> Int {
        let aprTxBytes : Int = TXService.aproximateSizeInBytes(inputsCount, outputsCount: outputsCount, isNeedFee: true)
        return aprTxBytes * fee
    }
    
    class func choseRightInputsModel(){
        
    }
    
    private class func aproximateSizeInBytes(inputsCount : Int, outputsCount : Int, isNeedFee : Bool) -> Int
    {
        let outPutToSelf = 1
        return averageInputCost * inputsCount + averageOuputCost * (outputsCount + ( isNeedFee ? outPutToSelf : 0 ) ) + 10
    }
}



