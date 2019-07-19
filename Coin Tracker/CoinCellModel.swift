
import Foundation

class CoinCellModel{
    
    internal let imageBase:String = "https://www.cryptocompare.com/"
    let imagePath:String?
    let coinName:String?
    let coinSymbol:String?
    let coinAlgo:String?
    let totalSuppy:String?
    let image_url: String?
    
    init(coinName:String?, coinSymbol:String?, coinAlgo:String?, totalSuppy:String?, imagePath:String?){
        
        self.coinName = coinName != nil ? coinName : ""
        self.coinSymbol = coinSymbol != nil ? coinSymbol : ""
        self.coinAlgo = coinAlgo != nil ? coinAlgo : ""
        self.totalSuppy = totalSuppy != nil ? totalSuppy : ""
        var img_path: String = imagePath != nil ? imagePath! : ""
        self.imagePath = "\(self.imageBase)\(img_path)"
        self.image_url = img_path
        
    }
    
}
