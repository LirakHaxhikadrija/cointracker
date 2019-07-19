
import UIKit
import AlamofireImage
import Alamofire
import SwiftyJSON
import CoreData

class DetailsController: UIViewController {

    //selectedCoin deklaruar me poshte mbushet me te dhena nga
    //controlleri qe e thrret kete screen (Shiko ListaController.swift)
    var selectedCoin:CoinCellModel!
    @IBOutlet weak var saveFavoriteButton: UIButton!
    
    //IBOutlsets jane deklaruar me poshte
    @IBOutlet weak var imgFotoja: UIImageView!
    @IBOutlet weak var lblDitaOpen: UILabel!
    @IBOutlet weak var lblDitaHigh: UILabel!
    @IBOutlet weak var lblDitaLow: UILabel!
    @IBOutlet weak var lbl24OreOpen: UILabel!
    @IBOutlet weak var lbl24OreHigh: UILabel!
    @IBOutlet weak var lbl24OreLow: UILabel!
    @IBOutlet weak var lblMarketCap: UILabel!
    @IBOutlet weak var lblCmimiBTC: UILabel!
    @IBOutlet weak var lblCmimiEUR: UILabel!
    @IBOutlet weak var lblCmimiUSD: UILabel!
    @IBOutlet weak var lblCoinName: UILabel!
    
    var is_favorite: Bool = false
    var coin_details: CoinDetailsModel?
    var coin_symbol: String = ""
    //APIURL per te marre te dhenat te detajume per coin
    //shiko: https://www.cryptocompare.com/api/ per detaje
    let APIURL = "https://min-api.cryptocompare.com/data/pricemultifull"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //brenda ketij funksioni, vendosja foton imgFotoja Outletit
        //duke perdorur AlamoFireImage dhe funksionin:
        //af_setImage(withURL:URL)
        //psh: imgFotoja.af_setImage(withURL: URL(string: selectedCoin.imagePath)!)
        self.imgFotoja.af_setImage(withURL: URL(string: (self.selectedCoin?.imagePath)!)!)
        
        //Te dhenat gjenerale per coin te mirren nga objekti selectedCoin
        self.lblCoinName.text = self.selectedCoin.coinName
        
        
        //Krijo nje dictionary params[String:String] per ta thirrur API-ne
        var parameters: [String:String] = [
            "fsyms" : (self.selectedCoin?.coinSymbol)!,
            "tsyms" : "USD,EUR,BTC"
        ]
        //parametrat qe duhet te jene ne kete params:
        //fsyms - Simboli i Coinit (merre nga selectedCoin.coinSymbol)
        //tsyms - llojet e parave qe na duhen: ""BTC,USD,EUR""
        checkIfFavorite()
        //Thirr funksionin getDetails me parametrat me siper
        getDetails(params: parameters)
    }
    
    func checkIfFavorite(){
        let coin_symbol: String = selectedCoin.coinSymbol!
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CoinFavorites")
        
        request.predicate = NSPredicate(format: "coin_symbol = %@", coin_symbol)
        request.returnsObjectsAsFaults = false
        do {
            
            let rezultati = try context.fetch(request)
            if rezultati.count > 0 {
                is_favorite = true
                saveFavoriteButton.titleLabel?.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
//                saveFavoriteButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
                saveFavoriteButton.setTitleColor(#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), for: .normal)
                saveFavoriteButton.isUserInteractionEnabled = false;
            }
            
        } catch {
            print("Gabim gjate Leximit")
        }
    }
    @IBAction func allButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func getDetails(params:[String:String]){
        //Thrret Alamofire me parametrat qe i jan jap funksionit
        //dhe te dhenat qe kthehen nga API te mbushin labelat
        //dhe pjeset tjera te view
        Alamofire.request(APIURL, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    let json = JSON(data)
                    print(json["DISPLAY"][self.selectedCoin.coinSymbol as! String]["BTC"]["PRICE"].stringValue)
                    var priceBTC: String = json["DISPLAY"][self.selectedCoin.coinSymbol as! String]["BTC"]["PRICE"].stringValue
                    var priceUSD: String = json["DISPLAY"][self.selectedCoin.coinSymbol as! String]["USD"]["PRICE"].stringValue
                    var priceEUR: String = json["DISPLAY"][self.selectedCoin.coinSymbol as! String]["EUR"]["PRICE"].stringValue
                    
                    var dayOpen: String = json["DISPLAY"][self.selectedCoin.coinSymbol as! String]["BTC"]["OPENDAY"].stringValue
                    var dayHigh: String = json["DISPLAY"][self.selectedCoin.coinSymbol as! String]["BTC"]["HIGHDAY"].stringValue
                    var dayLow: String = json["DISPLAY"][self.selectedCoin.coinSymbol as! String]["BTC"]["LOWDAY"].stringValue
                    
                    var hourOpen: String = json["DISPLAY"][self.selectedCoin.coinSymbol as! String]["BTC"]["OPEN24HOUR"].stringValue
                    var hourHigh: String = json["DISPLAY"][self.selectedCoin.coinSymbol as! String]["BTC"]["HIGH24HOUR"].stringValue
                    var hourLow: String = json["DISPLAY"][self.selectedCoin.coinSymbol as! String]["BTC"]["LOW24HOUR"].stringValue
                    
                    var marketCap: String = json["DISPLAY"][self.selectedCoin.coinSymbol as! String]["BTC"]["MKTCAP"].stringValue
                    self.coin_details = CoinDetailsModel(marketCap: marketCap, hourHigh: hourHigh, hourLow: hourLow, hourOpen: hourOpen, dayHigh: dayHigh, dayLow: dayLow, dayOpen: dayOpen, priceEUR: priceEUR, priceUSD: priceUSD, priceBTC: priceBTC)
                    self.setupUI()
                }
                break
                
            case .failure(_):

                break
                
            }
        }
        
    }
    
    func setupUI(){
        lblDitaOpen.text = coin_details?.dayOpen
        lblDitaHigh.text = coin_details?.dayHigh
        lblDitaLow.text = coin_details?.dayLow
        
        lbl24OreOpen.text = coin_details?.hourOpen
        lbl24OreHigh.text = coin_details?.hourHigh
        lbl24OreLow.text = coin_details?.hourLow
        
        lblMarketCap.text = coin_details?.marketCap
        lblCmimiBTC.text = coin_details?.priceBTC
        lblCmimiEUR.text = coin_details?.priceEUR
        lblCmimiUSD.text = coin_details?.priceUSD
    }
    @IBAction func saveToFavorite(_ sender: Any) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        
        let new_coin = NSEntityDescription.insertNewObject(forEntityName: "CoinFavorites", into: context)
        new_coin.setValue(selectedCoin.totalSuppy, forKey: "total_supply")
        new_coin.setValue(selectedCoin.imagePath, forKey: "image_path")
        new_coin.setValue(selectedCoin.coinSymbol, forKey: "coin_symbol")
        new_coin.setValue(selectedCoin.coinName, forKey: "coin_name")
        new_coin.setValue(selectedCoin.coinAlgo, forKey: "coin_algo")
        
        let alert = UIAlertController(title: "Alert", message: "Eshte ruajtur me sukses", preferredStyle: UIAlertControllerStyle.alert); alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)); self.present(alert, animated: true, completion: nil)
        
       

        do {
            saveFavoriteButton.setTitleColor(#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), for: .normal)
            self.saveFavoriteButton.isUserInteractionEnabled = false
            try context.save()
            
        } catch {
            print("Something went wrong")
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //IBAction mbylle - per butonin te gjitha qe mbyll ekranin
   
    
}

