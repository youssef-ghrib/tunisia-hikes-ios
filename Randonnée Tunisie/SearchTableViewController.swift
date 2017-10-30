//
//  SearchTableViewController.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 12/27/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import UIKit
import Alamofire

class SearchTableViewController: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredHikes = [Randonnee]()
    var map = [Int: Participation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor.init(red: 0.2, green: 0.8, blue: 0.5, alpha: 1)
        searchController.searchBar.tintColor = UIColor.white
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.scopeButtonTitles = ["All", "current", "canceled", "done"]
        searchController.searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/getAllRandonnees.php").responseArray { (response: DataResponse<[Randonnee]>) in
            
            let randonnees = response.result.value!
            
            self.filteredHikes = randonnees.filter { randonnee in
                let categoryMatch = (scope == "All") || (randonnee.status == scope)
                return categoryMatch && randonnee.title.lowercased().contains(searchText.lowercased())
            }
            
            Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/getParticipationsByUser.php?user_id=" + "\(self.getIdCurrentUser())").responseArray { (response: DataResponse<[Participation]>) in
                
                let participations = response.result.value!
                
                for participation in participations {
                    
                    self.map[participation.randonneeId] = participation
                }
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredHikes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)

        // Configure the cell...
        let randonnee = filteredHikes[indexPath.row]
        
        let img = cell.viewWithTag(10) as! UIImageView
        let title = cell.viewWithTag(20) as! UILabel
        let location = cell.viewWithTag(30) as! UILabel
        let date = cell.viewWithTag(40) as! UILabel
        
        let url = URL(string: randonnee.photo)
        img.kf.setImage(with: url)
        
        title.text = randonnee.title
        
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
        
        if(segue.identifier == "searchDetails"){
            
            let details:HikeViewController = segue.destination as! HikeViewController
            
            let indexPath = self.tableView.indexPathForSelectedRow
            
            let randonnee = filteredHikes[(indexPath?.row)!]
            
            details.randonnee = randonnee
            
            if let participation = map[randonnee.id] {
                
                details.participation = participation
            }
        }
    }
}

extension SearchTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
