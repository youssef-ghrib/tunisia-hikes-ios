//
//  LoginViewController.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 11/17/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import Alamofire

class LoginViewController: UIViewController, LoginButtonDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.center = view.center
        loginButton.delegate = self
        
        stackView.insertArrangedSubview(loginButton, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if AccessToken.current != nil {
            // User is logged in, use 'accessToken' here.
            fetchProfile()
        }
        let preferences = UserDefaults.standard
        
        if preferences.integer(forKey: "id") != 0 {
            
            performSegue(withIdentifier: "loginToMain", sender: self)
        }
    }
    
    func fetchProfile() {
        
        let parameters = ["fields": "first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: {
            (connection, result, error) -> Void in
            
            if error != nil {
                print(error!)
                return
            }
            
            guard let profile = result as? [String: Any] else {
                return
            }
            
            if let id = profile["id"] as? String, let firstName = profile["first_name"] as? String, let lastName = profile["last_name"] as? String, let picture = profile["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary, let url = data["url"] as? String {
                
                Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/getUserByFacebookId.php?id=" + id).responseObject { (response: DataResponse<User>) in
                    
                    if let user = response.result.value {
                        
                        let preferences = UserDefaults.standard
                        
                        preferences.set(user.id, forKey: "id")
                        preferences.set(user.idFacebook, forKey: "id_facebook")
                        preferences.set(user.name, forKey: "name")
                        preferences.set(user.photo, forKey: "photo")
                        preferences.set(user.thumbnail, forKey: "thumbnail")
                        
                        //  Save to disk
                        preferences.synchronize()
                        
                        self.performSegue(withIdentifier: "loginToMain", sender: self)
                        
                    } else {
                        
                        let parameters: Parameters = [
                            "id_facebook" : id,
                            "name" : firstName + " " + lastName,
                            "photo" : url
                        ]
                        
                        Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/createAccountViaFacebook.php", method: .post,parameters: parameters).responseObject { (response: DataResponse<User>) in
                            
                            if (response.response?.statusCode == 200) {
                                
                                let preferences = UserDefaults.standard
                                
                                let user = response.result.value!
                                
                                preferences.set(user.id, forKey: "id")
                                preferences.set(user.idFacebook, forKey: "id_facebook")
                                preferences.set(user.name, forKey: "name")
                                preferences.set(user.photo, forKey: "photo")
                                preferences.set(user.thumbnail, forKey: "thumbnail")
                                
                                //  Save to disk
                                preferences.synchronize()
                                
                                self.performSegue(withIdentifier: "loginToMain", sender: self)
                            }
                        }
                    }
                }
            }
        })
        
        //self.performSegue(withIdentifier: "loginToMain", sender: self)
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        
        fetchProfile()
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/getUserByEmail.php?email=" + email.text!).responseJSON { response in
            
            if let json = response.result.value {
                
                if((json as? NSDictionary) == nil){
                    
                    let alert = UIAlertController(title: "Alert", message: "This email is incorrect", preferredStyle:UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    
                    let result = json as! NSDictionary
                    let password = result.object(forKey: "password") as! NSString
                    
                    if(password.isEqual(to: self.password.text!)){
                        
                        let id = result.object(forKey: "id") as! NSInteger
                        let name = result.object(forKey: "name") as! NSString
                        let photo = result.object(forKey: "photo") as! NSString
                        let thumbnail = result.object(forKey: "thumbnail") as! NSString
                        let email = result.object(forKey: "email") as! NSString
                        let password = result.object(forKey: "password") as! NSString
                        
                        let preferences = UserDefaults.standard
                        
                        preferences.set(id, forKey: "id")
                        preferences.set(name, forKey: "name")
                        preferences.set(photo, forKey: "photo")
                        preferences.set(thumbnail, forKey: "thumbnail")
                        preferences.set(email, forKey: "email")
                        preferences.set(password, forKey: "password")
                        
                        //  Save to disk
                        preferences.synchronize()
                        
                        self.performSegue(withIdentifier: "loginToMain", sender: self)
                        
                    } else {
                        
                        let alert = UIAlertController(title: "Alert", message: "This password is incorrect",preferredStyle:UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
