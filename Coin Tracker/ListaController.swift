
import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage

// [DONE] Duhet te jete conform protocoleve per tabele
class ListaController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // [DONE] Krijo IBOutlet tableView nga View
    @IBOutlet weak var coinTableView: UITableView!
    
    // [DONE] Krijo nje var qe mban te dhena te tipit CoinCellModel
    var coin_cells = [CoinCellModel]()

    // [DONE] Krijo nje variable slectedCoin te tipit CoinCellModel!
    var selected_coin: CoinCellModel?
    
    //kjo perdoret per tja derguar Controllerit "DetailsController"
    //me poshte, kur ndodh kalimi nga screen ne screen (prepare for segue)
    
    
    //URL per API qe ka listen me te gjithe coins
    //per me shume detaje : https://www.cryptocompare.com/api/
    let APIURL = "https://min-api.cryptocompare.com/data/all/coinlist"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // [DONE] regjistro delegate dhe datasource per tableview
        coinTableView.delegate = self
        coinTableView.dataSource = self
        
        // [DONE] regjistro custom cell qe eshte krijuar me NIB name dhe
        //reuse identifier
         coinTableView.register(UINib(nibName: "CoinCell", bundle: nil), forCellReuseIdentifier: "coinCell")
        
        // [DONE] Thirr funksionin getDataFromAPI()
        getDataFromAPI()
    }
    
    //Funksioni getDataFromAPI()
    //Perdor alamofire per te thirre APIURL dhe ruan te dhenat
    //ne listen vargun me CoinCellModel
    //Si perfundim, thrret tableView.reloadData()
    func getDataFromAPI(){
        Alamofire.request(APIURL).responseJSON { response in
            switch response.result {
            case .success:
                if response.result.value != nil
                {
                    if let dict :[String: AnyObject] = response.result.value! as! [String: AnyObject]{
                       
                        if let data :[String: AnyObject] = dict["Data"] as! [String : AnyObject] {
                            for coin in data {
                                var coin_data = coin.value
                                print(coin_data["Symbol"] as! String)
                                self.coin_cells.append(CoinCellModel(coinName: coin_data["Name"] as? String, coinSymbol: coin_data["Symbol"] as? String, coinAlgo: coin_data["Algorithm"] as? String, totalSuppy: coin_data["TotalCoinSupply"] as? String, imagePath: coin_data["ImageUrl"] as? String))

                            }
                        }
                        self.coinTableView.reloadData()
                    }
                }
                break
            case .failure(let error):
                print("Error: \(error)")
                break
            }
        }

    }

    
    //Shkruaj dy funksionet e tabeles ketu
    //cellforrowat indexpath dhe numberofrowsinsection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coin_cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell", for: indexPath) as! CoinCell
        
        cell.lblEmri.text = coin_cells[indexPath.row].coinName as! String
        cell.lblSymboli.text = coin_cells[indexPath.row].coinSymbol as! String
        cell.lblTotali.text = coin_cells[indexPath.row].totalSuppy as! String
        cell.lblAlgoritmi.text = coin_cells[indexPath.row].coinAlgo as! String
        let image_url = URL(string: coin_cells[indexPath.row].imagePath as! String)
        let data = try! Data(contentsOf: image_url!)
        cell.imgFotoja.image = UIImage(data: data)
        
        return cell
    }
    
    
    //Funksioni didSelectRowAt indexPath merr parane qe eshte klikuar
    //Ruaj Coinin e klikuar tek selectedCoin variabla e deklarurar ne fillim
    //dhe e hap screenin tjeter duke perdore funksionin
    //performSeguew(withIdentifier: "EmriILidhjes", sender, self)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "shfaqDetajet", sender: indexPath.row)
    }
    
    
    //Beje override funksionin prepare(for segue...)
    //nese identifier eshte emri i lidhjes ne Storyboard.
    //controllerit tjeter ja vendosim si selectedCoin, coinin
    //qe e kemi ruajtur me siper
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "shfaqDetajet"
        {
            selected_coin = coin_cells[sender as! Int]
            let destination = segue.destination as! DetailsController
            destination.selectedCoin = selected_coin
        }
    }

}
