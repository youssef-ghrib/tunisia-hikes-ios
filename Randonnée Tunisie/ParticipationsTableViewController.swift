//
//  ParticipationsTableViewController.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 12/28/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import UIKit
import Alamofire

class ParticipationsTableViewController: UITableViewController {

    var hikes = [Randonnee]()
    var map = [Int: Participation]()
    var status = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/getParticipationsByUser.php?user_id=" + "\(self.getIdCurrentUser())").responseArray { (response: DataResponse<[Participation]>) in
            
            if response.response?.statusCode == 200 {
                
            let participations = response.result.value!
            
            for participation in participations {
                
                if participation.status == self.status {
                    
                    self.map[participation.randonneeId] = participation
                    
                    Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/getRandonneeById.php?id=" + "\(participation.randonneeId!)").responseObject { (response: DataResponse<Randonnee>) in
                        
                        if response.response?.statusCode == 200 {
                            
                            self.hikes.append(response.result.value!)
                        }
                        self.tableView.reloadData()
                    }
                }
                }
                self.tableView.reloadData()
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return hikes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
        
        // Configure the cell...
        let randonnee = hikes[indexPath.row]
        
        let img = cell.viewWithTag(10) as! UIImageView
        let title = cell.viewWithTag(20) as! UILabel
        let location = cell.viewWithTag(30) as! UILabel
        let date = cell.viewWithTag(40) as! UILabel
        let status = cell.viewWithTag(50) as! UILabel
        
        let url = URL(string: randonnee.photo)
        img.kf.setImage(with: url)
        
        title.text = randonnee.title
        status.text = randonnee.status
        
        if randonnee.status == "current" {
            status.textColor = UIColor.green
        }
        
        if randonnee.status == "canceled" {
            status.textColor = UIColor.red
        }
        
        if randonnee.status == "done" {
            status.textColor = UIColor.black
        }
        
        location.text = changeTimeFormat(date: randonnee.startTime, format: "ha") + " - " + changeTimeFormat(date: randonnee.endTime, format: "ha") + " @" + randonnee.location
        
        date.text = changeDateFormat(date: randonnee.date, format: "dd") + "/" + changeDateFormat(date: randonnee.date, format: "MM") + "/" + changeDateFormat(date: randonnee.date, format: "yyyy")
        
        return cell
    }
    
    func changeDateFormat(date : String, format : String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
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
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
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
    
    func getIdCurrentUser() -> Int{
        
        let preferences = UserDefaults.standard
        
        let id = preferences.integer(forKey: "id")
        
        return id
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "participationsDetails"){
            
            let details:HikeViewController = segue.destination as! HikeViewController
            
            let indexPath = self.tableView.indexPathForSelectedRow
            
            let randonnee = hikes[(indexPath?.row)!]
            
            details.randonnee = randonnee
            
            if let participation = map[randonnee.id] {
                
                details.participation = participation
            }
        }
    }
}
