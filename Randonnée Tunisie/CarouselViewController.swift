//
//  CarouselViewController.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 11/25/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import UIKit

class CarouselViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    var images = [Media]()
    var indexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        scrollView.frame = view.frame
        
        for i in 0..<images.count{
            
            let imageView = UIImageView()
            imageView.backgroundColor = UIColor.black
            
            let url = URL(string: images[i].url)
            imageView.kf.setImage(with: url)
            
            imageView.contentMode = .scaleAspectFit
            let xPosition = view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            
            scrollView.contentSize.width = scrollView.frame.width * CGFloat(i + 1)
            scrollView.addSubview(imageView)
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
