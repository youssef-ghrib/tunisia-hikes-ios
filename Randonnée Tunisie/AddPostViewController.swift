//
//  AddPostViewController.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 12/9/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import UIKit
import NohanaImagePicker
import Photos
import AVFoundation
import Kingfisher
import Alamofire

class AddPostViewController: UIViewController, NohanaImagePickerControllerDelegate {
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var postText: UITextField!
    
    @IBOutlet weak var postMedias_1: UIImageView!
    
    @IBOutlet weak var postMedias_2: UIStackView!
    
    @IBOutlet weak var img_2_1: UIImageView!
    @IBOutlet weak var img_2_2: UIImageView!
    
    @IBOutlet weak var postMedias_3: UIStackView!
    
    @IBOutlet weak var img_3_1: UIImageView!
    @IBOutlet weak var img_3_2: UIImageView!
    @IBOutlet weak var img_3_3: UIImageView!
    
    @IBOutlet weak var postMedias_4: UIStackView!
    
    @IBOutlet weak var img_4_1: UIImageView!
    @IBOutlet weak var img_4_2: UIImageView!
    @IBOutlet weak var img_4_3: UIImageView!
    @IBOutlet weak var img_4_4: UIImageView!
    
    @IBOutlet weak var postMedias_5: UIStackView!
    
    @IBOutlet weak var img_5_1: UIImageView!
    @IBOutlet weak var img_5_2: UIImageView!
    @IBOutlet weak var img_5_3: UIImageView!
    @IBOutlet weak var img_5_4: UIImageView!
    @IBOutlet weak var img_5_5: UIImageView!
    
    var randonnee: Randonnee = Randonnee()
    let preferences = UserDefaults.standard
    var pickedAssts = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let username = preferences.string(forKey: "name")
        let photo = preferences.string(forKey: "thumbnail")
        
        let url = URL(string: photo!)
        userImg.kf.setImage(with: url)
        
        userName.text = username
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addMedia(_ sender: UIButton) {
        
        let picker = NohanaImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func nohanaImagePickerDidCancel(_ picker: NohanaImagePickerController) {
        print("🐷Canceled🙅")
        picker.dismiss(animated: true, completion: nil)
    }
    
    func nohanaImagePicker(_ picker: NohanaImagePickerController, didFinishPickingPhotoKitAssets pickedAssts :[PHAsset]) {
        print("🐷Completed🙆\n\tpickedAssets = \(pickedAssts)")
        picker.dismiss(animated: true, completion: nil)
        
        self.pickedAssts = pickedAssts
        
        self.postMedias_1.image = nil
        self.img_2_1.image = nil
        self.img_2_2.image = nil
        self.img_3_1.image = nil
        self.img_3_2.image = nil
        self.img_3_3.image = nil
        self.img_4_1.image = nil
        self.img_4_2.image = nil
        self.img_4_3.image = nil
        self.img_4_4.image = nil
        self.img_5_1.image = nil
        self.img_5_2.image = nil
        self.img_5_3.image = nil
        self.img_5_4.image = nil
        self.img_5_5.image = nil
        
        let manager = PHImageManager()
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = false
        options.resizeMode = .fast
        
        switch(pickedAssts.count){
            
        case 1:
            
            manager.requestImage(for: pickedAssts[0], targetSize: CGSize(width: 340, height: 340), contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                
                self.postMedias_1.image = image
            })
            
            break
            
        case 2:
            
            manager.requestImage(for: pickedAssts[0], targetSize: CGSize(width: 166, height: 170), contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                
                self.img_2_1.image = image
            })
            manager.requestImage(for: pickedAssts[1], targetSize: CGSize(width: 166, height: 170), contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                
                self.img_2_2.image = image
            })
            
            break
            
        case 3:
            
            manager.requestImage(for: pickedAssts[0], targetSize: CGSize(width: 195, height: 282), contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                
                self.img_3_1.image = image
            })
            manager.requestImage(for: pickedAssts[1], targetSize: CGSize(width: 137, height: 137), contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                
                self.img_3_2.image = image
            })
            manager.requestImage(for: pickedAssts[2], targetSize: CGSize(width: 137, height: 137), contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                
                self.img_3_3.image = image
            })
            
            break
            
        case 4:
            
            manager.requestImage(for: pickedAssts[0], targetSize: CGSize(width: 340, height: 166), contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                
                self.img_4_1.image = image
            })
            manager.requestImage(for: pickedAssts[1], targetSize: CGSize(width: 108, height: 108), contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                
                self.img_4_2.image = image
            })
            manager.requestImage(for: pickedAssts[2], targetSize: CGSize(width: 108, height: 108), contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                
                self.img_4_3.image = image
            })
            manager.requestImage(for: pickedAssts[3], targetSize: CGSize(width: 108, height: 108), contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                
                self.img_4_4.image = image
            })
            
            break
            
        case 5:
            
            manager.requestImage(for: pickedAssts[0], targetSize: CGSize(width: 166, height: 166), contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                
                self.img_5_1.image = image
            })
            manager.requestImage(for: pickedAssts[1], targetSize: CGSize(width: 166, height: 166), contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                
                self.img_5_2.image = image
            })
            manager.requestImage(for: pickedAssts[2], targetSize: CGSize(width: 108, height: 108), contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                
                self.img_5_3.image = image
            })
            manager.requestImage(for: pickedAssts[3], targetSize: CGSize(width: 108, height: 108), contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                
                self.img_5_4.image = image
            })
            manager.requestImage(for: pickedAssts[4], targetSize: CGSize(width: 108, height: 108), contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                
                self.img_5_5.image = image
            })
            break
            
        default: break
        }
    }
    
    @IBAction func postAction(_ sender: UIBarButtonItem) {
        
        let manager = PHImageManager()
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        options.resizeMode = .none
        
        let parameters: Parameters = [
            "text" : self.postText.text!,
            "randonnee_id" : self.randonnee.id,
            "user_id" : self.preferences.integer(forKey: "id")
        ]
        
        Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/addPost.php", method: .post,parameters: parameters).responseString(completionHandler: { response in
            
            if (response.response?.statusCode == 200) {
                
                let postId = response.result.value
                
                if(self.pickedAssts.count == 0){
                    
                    self.dismiss(animated: true, completion: nil)
                } else {
                    
                    for i in 0..<self.pickedAssts.count {
                        
                        manager.requestImage(for: self.pickedAssts[i], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options, resultHandler: {(image, info) -> Void in
                            
                            Alamofire.upload(multipartFormData: {
                                multipartFormData in
                                
                                multipartFormData.append((postId?.data(using: .utf8))!, withName: "post_id")
                                multipartFormData.append(self.encodeImage(image: image!), withName: "media")
                                
                            }, to: "https://randonnee-tunisie.000webhostapp.com/randonnee/addMedia.php", encodingCompletion: {
                                encodingResult in
                                switch encodingResult{
                                case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                                    upload.responseString(completionHandler: {
                                        response in
                                        debugPrint(response)
                                        
                                        if i == self.pickedAssts.count - 1 {
                                            
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    })
                                    break
                                case .failure(let encodingError):
                                    print(encodingError)
                                    break
                                }
                            })
                        })
                    }
                }
            }
        })
    }
    
    func encodeImage(image:UIImage) -> Data {
        
        let imageData:NSData = UIImageJPEGRepresentation(image, 1) as NSData!
        let dataBase64:Data = imageData.base64EncodedData(options: [])
        
        return dataBase64
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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
