//
//  EditProfileViewController.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 11/18/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import UIKit
import Alamofire

class EditProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var reEnterPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.contentSize.height = 603
        
        imagePicker.delegate = self
        
        profileImg.isUserInteractionEnabled = true
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTapping(recognizer:)))
        
        singleTap.numberOfTapsRequired = 1;
        profileImg.addGestureRecognizer(singleTap)
        
        currentPassword.delegate = self
        
        let preferences = UserDefaults.standard
        
        let username = preferences.string(forKey: "name")
        let photo = preferences.string(forKey: "photo")
        let mail = preferences.string(forKey: "email")
                
        let url = URL(string: photo!)
        profileImg.kf.setImage(with: url)
        
        name.text = username
        email.text = mail;
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if(textView.text.characters.count != 0) {
            
            newPassword.isEnabled = true;
            reEnterPassword.isEnabled = true
        
        } else {
            
            newPassword.isEnabled = false;
            reEnterPassword.isEnabled = false
        }
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
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        let username = name.text
        let mail = email.text
        
        let preferences = UserDefaults.standard
        
        var password = preferences.string(forKey: "password")
        
        if (!(currentPassword.text?.isEmpty)!) {
            
            if (!validatePasswords()) {
                
                let alert = UIAlertController(title: "Alert", message: "Please check your passwords and try again", preferredStyle:UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            password = newPassword.text!
        }
        
        updateUser(id: getIdCurrentUser(), name: username!, email: mail!, password: password!);
    }
    
    func validatePasswords() -> Bool {
    var valid = true;
    
        let pwd = newPassword.text
        let reEnterPassword = self.reEnterPassword.text

    if (reEnterPassword!.isEmpty || !(reEnterPassword == pwd)) {

        valid = false;
    }
    
    return valid;
    }
    
    func updateUser(id : Int, name : String, email : String, password : String) {
        
        var photo : String
        
        if(profileImg.image == nil){
            
            photo = ""
            
        } else  {
            
            photo = encodeImage(image: profileImg.image!)
        }
        
        let parameters: Parameters = [
            "id" : getIdCurrentUser(),
            "email": email,
            "name": name,
            "password": password,
            "photo": photo
        ]
        
        Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/getUserByEmail.php?email=" + email).responseJSON { response in
            
            if let json = response.result.value {
                
                if((json as? NSDictionary) == nil){
                    
                    Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/updateAccount.php", method: .post,parameters: parameters).responseJSON { response in
                        
                        if (response.response?.statusCode == 200) {
                            
                            let preferences = UserDefaults.standard
                            
                            preferences.set(id, forKey: "id")
                            preferences.set(name, forKey: "name")
                            preferences.set(photo, forKey: "photo")
                            preferences.set(email, forKey: "email")
                            preferences.set(password, forKey: "password")
                            
                            //  Save to disk
                            preferences.synchronize()
                        }
                    }
                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    
                    let alert = UIAlertController(title: "Alert", message: "An account with this email adress already exists", preferredStyle:UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
