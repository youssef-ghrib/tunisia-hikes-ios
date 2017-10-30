//
//  ProfileViewController.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 11/18/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImg: UIImageView!
    
    @IBOutlet weak var name: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let preferences = UserDefaults.standard
        
        let username = preferences.string(forKey: "name")
        let photo = preferences.string(forKey: "photo")

        let url = URL(string: photo!)
        profileImg.kf.setImage(with: url)
        
        name.text = username
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signoutAction(_ sender: UIButton) {
        
        if AccessToken.current != nil {
            // User is logged in, use 'accessToken' here.
            let loginManager = LoginManager()
            loginManager.logOut()
        }
        
        let preferences = UserDefaults.standard
        
        preferences.set(0, forKey: "id")
        preferences.set(0, forKey: "id_facebook")
        preferences.set("", forKey: "name")
        preferences.set("", forKey: "email")
        preferences.set("", forKey: "photo")
        preferences.set("", forKey: "thumbnail")
        
        //  Save to disk
        preferences.synchronize()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "going"){
            
            let participations:ParticipationsTableViewController = segue.destination as! ParticipationsTableViewController
            
            participations.status = "going"
        }
        
        if(segue.identifier == "wishlist"){
            
            let participations:ParticipationsTableViewController = segue.destination as! ParticipationsTableViewController
            
            participations.status = "wishlist"
        }
    }
}
