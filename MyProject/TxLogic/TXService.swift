import Foundation

class TXService {
    
    class func calculateMinersFee(inputsCount : Int, outputsCount : Int, fee : Int ) -> Int {
        let aprTxBytes : Int = TXService.aproximateSizeInBytes(inputsCount, outputsCount: outputsCount)
        return aprTxBytes * fee
    }
    
    class func choseRightInputsModel(){
        
    }
    
    private class func aproximateSizeInBytes(inputsCount : Int, outputsCount : Int) -> Int
    {
        return 180 * inputsCount + 34 * outputsCount + 10
    }
}



