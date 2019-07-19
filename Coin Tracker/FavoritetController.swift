
import UIKit
import CoreData

//Klasa permbane tabele kshtuqe duhet te kete
//edhe protocolet per tabela
class FavoritetController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var favorites_table_view: UITableView!
    
    var coin_cells = [CoinCellModel]()
    var selected_coin: CoinCellModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favorites_table_view.delegate = self
        favorites_table_view.dataSource = self
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CoinFavorites")
        request.returnsObjectsAsFaults = false
        
        do {

            let rezultati = try context.fetch(request)

            for elementi in rezultati as! [NSManagedObject]{
                
                self.coin_cells.append(CoinCellModel(coinName: elementi.value(forKey: "coin_name") as? String, coinSymbol: elementi.value(forKey: "coin_symbol") as? String, coinAlgo: elementi.value(forKey: "coin_algo") as? String, totalSuppy: elementi.value(forKey: "total_supply") as? String, imagePath: elementi.value(forKey: "image_path") as? String))

                if let username = elementi.value(forKey: "coin_name") as? String{
                    print(username)
                }
            }
            favorites_table_view.reloadData()
            
            
        } catch {
            print("Gabim gjate Leximit")
        }
        
        
        favorites_table_view.register(UINib(nibName: "CoinCell", bundle: nil), forCellReuseIdentifier: "coinCell")

    }

    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coin_cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell", for: indexPath) as! CoinCell
        
        cell.lblEmri.text = coin_cells[indexPath.row].coinName as! String
        cell.lblSymboli.text = coin_cells[indexPath.row].coinSymbol as! String
        cell.lblTotali.text = coin_cells[indexPath.row].totalSuppy as! String
        cell.lblAlgoritmi.text = coin_cells[indexPath.row].coinAlgo as! String
        let image_url = URL(string: coin_cells[indexPath.row].image_url as! String)
        let data = try! Data(contentsOf: image_url!)
        cell.imgFotoja.image = UIImage(data: data)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "shfaqDetajet", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let coin_symbol: String = coin_cells[indexPath.row].coinSymbol!
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CoinFavorites")

            request.predicate = NSPredicate(format: "coin_symbol = %@", coin_symbol)
            request.returnsObjectsAsFaults = false
            do {
                
                let rezultati = try context.fetch(request)
                for elementi in rezultati as! [NSManagedObject]{

                    context.delete(elementi)
                    coin_cells.remove(at: indexPath.row)
                    
                }
                
            } catch {
                print("Gabim gjate Leximit")
            }
        }
        favorites_table_view.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "shfaqDetajet"
        {
            selected_coin = coin_cells[sender as! Int]
            let destination = segue.destination as! DetailsController
            destination.selectedCoin = selected_coin
        }
    }
    
}
