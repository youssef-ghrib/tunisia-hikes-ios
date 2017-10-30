//
//  HomeTableViewController.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 11/17/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import Kingfisher

class HomeTableViewController: UITableViewController {
    
    var id:Int = 0
    var cachedImages = [String: UIImage]()
    var randonnees = [Randonnee]()
    var map = [Int: Participation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        id = getIdCurrentUser();
        getAllHikes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return randonnees.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
        
        // Configure the cell...
        let img:UIImageView = cell.viewWithTag(1) as! UIImageView
        let day:UILabel=cell.viewWithTag(2) as! UILabel
        let month:UILabel=cell.viewWithTag(3) as! UILabel
        let title:UILabel=cell.viewWithTag(4) as! UILabel
        let time:UILabel=cell.viewWithTag(5) as! UILabel
        let wishlist:UIButton=cell.viewWithTag(6) as! UIButton
        
        let randonnee : Randonnee = randonnees[indexPath.row]
        
        let url = URL(string: randonnee.photo!)
        img.kf.setImage(with: url)
        
        day.text = changeDateFormat(date: randonnee.date!, format: "dd")
        month.text = changeDateFormat(date: randonnee.date!, format: "MMM")
        title.text = randonnee.title
        time.text = changeTimeFormat(date: randonnee.startTime!, format: "ha") + " - " + changeTimeFormat(date: randonnee.endTime!, format: "ha") + " @" + randonnee.location!
        
        if let participation = map[randonnee.id] {
            
            if participation.status == "wishlist" {
                
                wishlist.setImage(UIImage(named: "heart_filled_60"), for: UIControlState.normal)
            }
        }
        
        return cell
    }
    
    func changeDateFormat(date : String, format : String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        //        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        let dateObj = dateFormatter.date(from: date)
        
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: dateObj!)
    }
    
    func changeTimeFormat(date : String, format : String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        //        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        let dateObj = dateFormatter.date(from: date)
        
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: dateObj!)
    }
    
    func getAllHikes(){
    
        Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/getAllRandonnees.php").responseArray { (response: DataResponse<[Randonnee]>) in
            
            self.randonnees = response.result.value!
            
            Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/getParticipationsByUser.php?user_id=" + "\(self.getIdCurrentUser())").responseArray { (response: DataResponse<[Participation]>) in
                
                let participations = response.result.value!
                
                for participation in participations {
                    
                    self.map[participation.randonneeId] = participation
                }
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func wishlist(_ sender: UIButton) {
        var indexPath: NSIndexPath!
        if let superview = sender.superview?.superview?.superview?.superview?.superview {
            if let cell = superview.superview as? UITableViewCell {
                indexPath = self.tableView.indexPath(for: cell) as NSIndexPath!
            }
        }
        let randonnee : Randonnee = randonnees[indexPath.row]
        
        Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/checkParticipation.php?randonnee=" + "\(randonnee.id!)" + "&user=" + String(id)).responseJSON { response in
            
            if let json = response.result.value {
                
                if((json as? NSDictionary) != nil){
                    
                    let result = json as! NSDictionary
                    let status = result.object(forKey: "status") as! NSString
                    
                    let parameters: Parameters = [
                        "randonnee": "\(randonnee.id!)",
                        "user": String(self.id),
                        "status": status
                    ]
                    
                    Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/updateWishlist.php", method: .post,parameters: parameters).responseJSON { response in
                        
                        if (response.response?.statusCode == 200) {
                            
                            if(status.isEqual(to: "going")){
                                
                                sender.setImage(UIImage(named: "heart_filled_60"), for: UIControlState.normal)
                                
                            } else {
                                
                                sender.setImage(UIImage(named: "heart_60"), for: UIControlState.normal)
                                
                            }
                        }
                    }
                    
                } else {
                    
                    let parameters: Parameters = [
                        "randonnee": "\(randonnee.id!)",
                        "user": String(self.id),
                        "status": "wishlist"
                    ]
                    
                    Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/addParticipation.php", method: .post,parameters: parameters).responseJSON { response in
                        
                        if (response.response?.statusCode == 200) {
                            
                            sender.setImage(UIImage(named: "heart_filled_60"), for: UIControlState.normal)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func getIdCurrentUser() -> Int{
        
        let preferences = UserDefaults.standard
        
        let id = preferences.integer(forKey: "id")
        
        return id
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "details"){
            
            let details:HikeViewController = segue.destination as! HikeViewController
            
            let indexPath = self.tableView.indexPathForSelectedRow
            
            let randonnee = randonnees[(indexPath?.row)!]
            
            details.randonnee = randonnee
            
            if let participation = map[randonnee.id] {
                
                details.participation = participation
            }
        }
    }
}
