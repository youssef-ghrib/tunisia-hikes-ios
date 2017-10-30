//
//  NewHikeFormViewController.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 11/18/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import Eureka
import CoreLocation
import ImageRow
import Alamofire

class NewHikeFormViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form = Section()
            <<< ImageRow("picture") { row in
                row.title = "Picture"
                row.sourceTypes = .PhotoLibrary
                row.clearAction = .yes(style: UIAlertActionStyle.destructive)
            }
            .cellUpdate { cell, row in
                cell.accessoryView?.layer.cornerRadius = 17
                cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
            }
            +++ Section("Basic Info")
            <<< TextRow("title"){ row in
                row.placeholder = "Title"
            }
            <<< LocationRow("location"){
                $0.title = "Location"
                $0.value = CLLocation(latitude: 33.7207818, longitude: 5.065619)
            }
            <<< TextAreaRow("description"){ row in
                row.placeholder = "Description"
            }
            +++ Section("Time & Date")
            <<< DateRow("date"){
                $0.title = "Date"
                $0.value = NSDate(timeIntervalSinceReferenceDate: 0) as Date
            }
            <<< TimeRow("start_time"){
                $0.title = "Start time"
                
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                
                $0.dateFormatter = formatter
                $0.value = NSDate(timeIntervalSinceReferenceDate: 0) as Date
            }
            <<< TimeRow("end_time"){
                $0.title = "End time"
                $0.value = NSDate(timeIntervalSinceReferenceDate: 0) as Date
            }
            +++ Section("Visibility")
            <<< SwitchRow("visibility"){
                $0.title = "Private"
                $0.value = false
            }
            +++ Section("Privacy")
            <<< SwitchRow("privacy"){
                $0.title = "Requires review"
                $0.value = false
            }
            +++ Section("Availability")
            <<< StepperRow("availability") {
                $0.title = "Number of participants"
                $0.value = 20
            }
            +++ Section()
            <<< SliderRow("cost") {
                $0.title = "Cost"
                $0.value = 10
                $0.maximumValue = 100
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        // Get the value of all rows which have a Tag assigned
        // The dictionary contains the 'rowTag':value pairs.
        let valuesDictionary = form.values()
        
        var type : String;
        
        if(valuesDictionary["visibility"]  as! Bool == true){
            
            type = "private"
        
        } else {
            
            type = "public"
        }
        
        let parameters: Parameters = [
        "title" : valuesDictionary["title"] as! String,
        //"location" : valuesDictionary["location"] as! CLLocation,
            "location" : "Nabeul",
            "longitude" : 10.5,
            "latitude" : 10.5,
        "date" : valuesDictionary["date"] as! Date,
        "start_time" : valuesDictionary["start_time"] as! Date,
        "end_time" : valuesDictionary["end_time"] as! Date,
        "description" : valuesDictionary["description"] as! String,
        "validation" : valuesDictionary["privacy"] as! Bool,
        "picture" : encodeImage(image: valuesDictionary["picture"] as! UIImage),
        "availability" : valuesDictionary["availability"] as! Double,
        "cost" : valuesDictionary["cost"] as! Float,
        "type" : type,
        "user_id" : getIdCurrentUser()
        ]
        
        Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/newHike.php", method: .post,parameters: parameters).responseJSON { response in

            if (response.response?.statusCode == 200) {
         
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func encodeImage(image:UIImage) -> String {
        
        let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
        let strBase64:String? = imageData.base64EncodedString(options : .lineLength64Characters)
        
        return strBase64!
    }
    
    func getIdCurrentUser() -> Int{
        
        let preferences = UserDefaults.standard
        
        let id = preferences.integer(forKey: "id")
        
        return id
}
}
