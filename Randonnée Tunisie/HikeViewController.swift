//
//  HikeViewController.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 11/27/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import SKPhotoBrowser
import FacebookShare

class HikeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    var id:Int = 0
    var randonnee: Randonnee = Randonnee()
    var participation: Participation? = nil
    
    @IBOutlet weak var hikeImg: UIImageView!
    @IBOutlet weak var hikeTitle: UILabel!
    @IBOutlet weak var hikeType: UILabel!
    @IBOutlet weak var hikeParticipants: UILabel!
    
    @IBOutlet weak var wishlistButton: UIButton!
    @IBOutlet weak var goingButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    var yPosition : CGFloat!
    
    var participantImgs = [String]()
    var posts = [Post]()
    
    override func viewWillAppear(_ animated: Bool) {
        id = getIdCurrentUser();
        
        getAllGoing()
        getAllPosts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let url = URL(string: randonnee.photo!)
        hikeImg.kf.setImage(with: url)
        
        hikeTitle.text = randonnee.title
        hikeType.text = randonnee.type! + " hike"
        
        hikeImg.alpha = 1
        
        yPosition = contentView.frame.origin.y
        
        if participation != nil {
            
            if participation?.status == "going" {
                
                goingButton.setImage(UIImage(named: "checked_filled_60"), for: UIControlState.normal)
                
            } else if participation?.status == "wishlist" {
                
                wishlistButton.setImage(UIImage(named: "heart_filled_60"), for: UIControlState.normal)
            }
        }
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        
        if let window = UIApplication.shared.keyWindow{
            
            window.addGestureRecognizer(swipeUp)
            window.addGestureRecognizer(swipeDown)
        }
    }
    
    func handleSwipe(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.down:
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    
                    self.contentView.frame = CGRect(x: 0, y: self.yPosition, width: self.contentView.frame.width, height: self.contentView.frame.height)
                    self.hikeImg.frame = CGRect(x: 0, y: 64, width: self.hikeImg.frame.width, height: self.hikeImg.frame.height)
                    self.hikeImg.alpha = 1
                    
                }, completion: nil)
                
                self.tableView.isScrollEnabled = true
                
            case UISwipeGestureRecognizerDirection.up:
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    
                    self.contentView.frame = CGRect(x: 0, y: 64, width: self.contentView.frame.width, height: self.contentView.frame.height)
                    self.hikeImg.frame = CGRect(x: 0, y: -(self.hikeImg.frame.height / 2), width: self.hikeImg.frame.width, height: self.hikeImg.frame.height)
                    self.hikeImg.alpha = 0
                    
                }, completion: nil)
                
                self.tableView.isScrollEnabled = true
                
            default:
                break
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height) && contentView.frame.origin.y == yPosition) {
            
            //user has scrolled to the bottom
            self.tableView.isScrollEnabled = false
        }
        
        if (scrollView.contentOffset.y == 0) {
         
            //user has scrolled to the top
            self.tableView.isScrollEnabled = false
        }
    }
    
    let blackView = UIView()
    let popupView = UIView()
    
    @IBAction func moreAction(_ sender: UIButton) {
        
        if let window = UIApplication.shared.keyWindow{
            
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            blackView.frame = window.frame
            blackView.alpha = 0
            
            popupView.backgroundColor = UIColor.groupTableViewBackground
            popupView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 182)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                
                self.blackView.alpha = 1
                
                self.popupView.frame = CGRect(x: 0, y: window.frame.height - 182, width: window.frame.width, height: window.frame.height)
                
            }, completion: nil)
            
            let map = UIButton(frame: CGRect(x: 8, y: 8, width: Int(view.frame.width) - 16, height: 50))
            map.setImage(#imageLiteral(resourceName: "Map Marker-48"), for: .normal)
            map.setTitle("Find on map", for: .normal)
            map.setTitleColor(UIColor.black, for: .normal)
            map.contentHorizontalAlignment = .left
            map.addTarget(self, action: #selector(mapAction), for: .touchUpInside)
            
            let album = UIButton(frame: CGRect(x: 8, y: 66, width: Int(view.frame.width) - 16, height: 50))
            album.setImage(#imageLiteral(resourceName: "Gallery-48"), for: .normal)
            album.setTitle("See photo gallery", for: .normal)
            album.setTitleColor(UIColor.black, for: .normal)
            album.contentHorizontalAlignment = .left
            album.addTarget(self, action: #selector(albumAction), for: .touchUpInside)
            
            let share = UIButton(frame: CGRect(x: 8, y: 124, width: Int(view.frame.width) - 16, height: 50))
            share.setImage(#imageLiteral(resourceName: "Forward Arrow Filled-48"), for: .normal)
            share.setTitle("Share to Facebook", for: .normal)
            share.setTitleColor(UIColor.black, for: .normal)
            share.contentHorizontalAlignment = .left
            share.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
            
            popupView.addSubview(map)
            popupView.addSubview(album)
            popupView.addSubview(share)
            
            window.addSubview(blackView)
            window.addSubview(popupView)
        }
    }
    
    func handleDismiss(){
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow{
                
                self.popupView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 120)
            }
        })
    }
    
    func albumAction(sender: UIButton){
        
        Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/getAllMediaByHike.php?randonnee_id=" + "\(self.randonnee.id!)").responseArray { (response: DataResponse<[Media]>) in
            
            let medias = response.result.value!
            
            // 1. create URL Array
            var images = [SKPhoto]()
            
            for media in medias {
                
                let photo = SKPhoto.photoWithImageURL(media.thumbnail)
                photo.shouldCachePhotoURLImage = true // you can use image cache by true(NSCache)
                images.append(photo)
            }
            // 2. create PhotoBrowser Instance, and present.
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(0)
            self.present(browser, animated: true, completion: {
                self.handleDismiss()
            })
        }
    }
    
    func mapAction(sender: UIButton){
        
        self.performSegue(withIdentifier: "map", sender: self)
    }
    
    func shareAction(sender: UIButton){
        
        let content = LinkShareContent(url: URL(string: "www.google.com")!, title: randonnee.title, description: randonnee.description, quote: randonnee.location, imageURL: URL(string: randonnee.photo))
        
        let shareDialog = ShareDialog(content: content)
        shareDialog.mode = .native
        shareDialog.failsOnInvalidData = true
        shareDialog.completion = { result in
            // Handle share results
        }
        
        do {
            try shareDialog.show()
            
        } catch {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as UITableViewCell
        
        let img:UIImageView = cell.viewWithTag(10) as! UIImageView
        let name:UILabel = cell.viewWithTag(20) as! UILabel
        let text:UILabel = cell.viewWithTag(30) as! UILabel
        
        let post : Post = posts[indexPath.row]
        
        text.text = post.text
        name.text = post.user.name
        
        let url = URL(string: post.user.thumbnail)
        img.kf.setImage(with: url)
        
        if let medias = post.medias {
            
            let imageView:UIImageView = cell.viewWithTag(40) as! UIImageView
            let nbr:UILabel = cell.viewWithTag(50) as! UILabel
            
            let click = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
            imageView.addGestureRecognizer(click)
            
            let url = URL(string: medias[0].thumbnail)
            
            if medias.count > 1 {
                
                let processor = BlurImageProcessor(blurRadius: 1)
                imageView.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)])
                
                nbr.text = "+" + String(medias.count - 1)
            } else {
                imageView.kf.setImage(with: url)
                nbr.text = ""
            }
        }
        return cell
    }
    
    func handleImageTap(recognizer: UITapGestureRecognizer) {
        
        guard let imageView = recognizer.view as? UIImageView
            else {
                return
        }
        let cell = imageView.superview?.superview as! UITableViewCell
        let indexPath = self.tableView.indexPath(for: cell)
        let post = posts[indexPath!.row]
        
        // 1. create URL Array
        var images = [SKPhoto]()
        
        for media in post.medias {
            
            let photo = SKPhoto.photoWithImageURL(media.thumbnail)
            photo.shouldCachePhotoURLImage = true // you can use image cache by true(NSCache)
            images.append(photo)
        }
        // 2. create PhotoBrowser Instance, and present.
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(0)
        self.present(browser, animated: true, completion: {})
    }
    
    func getAllGoing(){
        
        Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/getAllGoing.php?randonnee_id=" + "\(randonnee.id!)").responseArray { (response: DataResponse<[User]>) in
            
            let users = response.result.value
                    
                    for user in users! {
                        
                        self.participantImgs.append(user.thumbnail!)
                    }
            
                    for i in 0..<self.participantImgs.count{
                        
                        let participantImg = UIImageView()
                        
                        let url = URL(string: self.participantImgs[i])
                        participantImg.kf.setImage(with: url)
                        
                        participantImg.contentMode = .scaleAspectFill
                        let xPosition = 60 * CGFloat(i)
                        participantImg.frame = CGRect(x: xPosition, y: 0, width: 50, height: 50)
                        
                        participantImg.layer.borderWidth = 1
                        participantImg.layer.masksToBounds = false
                        participantImg.layer.borderColor = UIColor.lightText.cgColor
                        participantImg.layer.cornerRadius = participantImg.frame.height/2
                        participantImg.clipsToBounds = true
                        
                        self.scrollView.contentSize.width = 60 * CGFloat(i + 1)
                        self.scrollView.addSubview(participantImg)
                    }
                    self.hikeParticipants.text = String(self.participantImgs.count) + " Going"
                }
    }
    
    func getAllPosts(){

        Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/getAllPosts.php?randonnee_id=" + "\(randonnee.id!)").responseArray { (response: DataResponse<[Post]>) in
            
            self.posts = response.result.value!
            
            for post in self.posts {
                
                Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/getUserById.php?id=" + "\(post.userId!)").responseObject { (response: DataResponse<User>) in
                    
                    let user = response.result.value
                    
                    post.user = user
                    
                    Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/getAllMediaByPost.php?post_id=" + "\(post.id!)").responseArray { (response: DataResponse<[Media]>) in
                        
                        let medias = response.result.value
                        
                        post.medias = medias
                        
                        self.tableView.reloadData()
                }
            }
        }
    }
    }
    
    @IBAction func wishlistAction(_ sender: UIButton) {
        
        Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/checkParticipation.php?randonnee=" + "\(randonnee.id!)" + "&user=" + String(id)).responseJSON { response in
            
            if let json = response.result.value {
                
                if((json as? NSDictionary) != nil){
                    
                    let result = json as! NSDictionary
                    let status = result.object(forKey: "status") as! NSString
                    
                    let parameters: Parameters = [
                        "randonnee": "\(self.randonnee.id!)",
                        "user": String(self.id),
                        "status": status
                    ]
                    
                    Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/updateWishlist.php", method: .post,parameters: parameters).responseJSON { response in
                        
                        if (response.response?.statusCode == 200) {
                            
                            if(status.isEqual(to: "going")){
                                
                                sender.setImage(UIImage(named: "heart_filled_60"), for: UIControlState.normal)
                                self.goingButton.setImage(UIImage(named: "checked_60"), for: UIControlState.normal)
                                
                            } else {
                                
                                sender.setImage(UIImage(named: "heart_60"), for: UIControlState.normal)
                            }
                        }
                    }
                    
                } else {
                    
                    let parameters: Parameters = [
                        "randonnee": "\(self.randonnee.id!)",
                        "user": String(self.id),
                        "status": "wishlist"
                    ]
                    
                    Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/addParticipation.php", method: .post,parameters: parameters).responseJSON { response in
                        
                        if (response.response?.statusCode == 200) {
                            
                            sender.setImage(UIImage(named: "heart_filled_60"), for: UIControlState.normal)
                            self.goingButton.setImage(UIImage(named: "checked_60"), for: UIControlState.normal)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func goingAction(_ sender: UIButton) {
        
        Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/checkParticipation.php?randonnee=" + "\(randonnee.id!)" + "&user=" + String(id)).responseJSON { response in
            
            if let json = response.result.value {
                
                if((json as? NSDictionary) != nil){
                    
                    let result = json as! NSDictionary
                    let status = result.object(forKey: "status") as! NSString
                    
                    let parameters: Parameters = [
                        "randonnee": "\(self.randonnee.id!)",
                        "user": String(self.id),
                        "status": status
                    ]
                    
                    Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/updateGoing.php", method: .post,parameters: parameters).responseJSON { response in
                        
                        if (response.response?.statusCode == 200) {
                            
                            if(status.isEqual(to: "wishlist")){
                                
                                sender.setImage(UIImage(named: "checked_filled_60"), for: UIControlState.normal)
                                self.wishlistButton.setImage(UIImage(named: "heart_60"), for: UIControlState.normal)
                                
                            } else {
                                
                                sender.setImage(UIImage(named: "checked_60"), for: UIControlState.normal)
                            }
                        }
                    }
                    
                } else {
                    
                    let parameters: Parameters = [
                        "randonnee": "\(self.randonnee.id!)",
                        "user": String(self.id),
                        "status": "going"
                    ]
                    
                    Alamofire.request("https://randonnee-tunisie.000webhostapp.com/randonnee/addParticipation.php", method: .post,parameters: parameters).responseJSON { response in
                        
                        if (response.response?.statusCode == 200) {
                            
                            sender.setImage(UIImage(named: "checked_filled_60"), for: UIControlState.normal)
                            self.wishlistButton.setImage(UIImage(named: "heart_60"), for: UIControlState.normal)
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "add_post"){
            
            let addPost:AddPostViewController = segue.destination as! AddPostViewController
            
            addPost.randonnee = self.randonnee
        }
        if(segue.identifier == "map"){
            
            let location:LocationViewController = segue.destination as! LocationViewController
            
            location.longitude = self.randonnee.longitude
            location.latitude = self.randonnee.latitude
            location.location = self.randonnee.location
        }
    }
}
