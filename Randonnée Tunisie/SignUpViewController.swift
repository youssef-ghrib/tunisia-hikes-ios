//
//  SignUpViewController.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 11/17/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rePassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        
        profileImg.isUserInteractionEnabled = true
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTapping(recognizer:)))
        
        singleTap.numberOfTapsRequired = 1;
        profileImg.addGestureRecognizer(singleTap)
    }
    
    func singleTapping(recognizer: UIGestureRecognizer) {
        
        let alert = UIAlertController(title: "Upload picture", message: nil, preferredStyle:UIAlertControllerStyle.actionSheet)
        
        let photoLibraryAction = UIAlertAction(title: "From photo library", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.openPhotoLibrary()
        }
        
        let cameraAction = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.openPhotoLibrary()
        }
        
        alert.addAction(photoLibraryAction)
        alert.addAction(cameraAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openPhotoLibrary(){
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera(){
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImg.contentMode = .scaleAspectFit
            profileImg.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func signUp(_ sender: UIButton) {
        
        var photo : String
        
        if(profileImg.image == nil){
            
            photo = ""
            
        } else  {
            
            photo = encodeImage(image: profileImg.image!)
        }
        
        let parameters: Parameters = [
            "email": email.text!,
            "name": name.text!,
            "password": password.text!,
            "photo": photo
        ]
        
        if(password.text == rePassword.text){
            
            Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/getUserByEmail.php?email=" + email.text!).responseJSON { response in
                
                if let json = response.result.value {
                    
                    if((json as? NSDictionary) == nil){
                        
                        Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/createAccount.php", method: .post,parameters: parameters).responseJSON { response in
                            
                            if (response.response?.statusCode == 200) {
                                
                                if let json = response.result.value {
                                    
                                    let result = json as! NSDictionary
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
                                }
                                
                                
                                
                                self.performSegue(withIdentifier: "signUpToMain", sender: self)
                            }
                        }
                        
                    } else {
                        
                        let alert = UIAlertController(title: "Alert", message: "An account with this email adress already exists", preferredStyle:UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            
            let alert = UIAlertController(title: "Alert", message: "Passwords do not match", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func encodeImage(image:UIImage) -> String {
        
        let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
        let strBase64:String? = imageData.base64EncodedString(options : .lineLength64Characters)
        
        return strBase64!
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
