//
//  ImagesViewController.swift
//  Randomly Beautiful
//
//  Created by Dixita Bhargava on 27/06/20.
//  Copyright © 2020 Dixita Bhargava. All rights reserved.
//

import UIKit

class ImagesViewController: UIViewController {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var category = ""
    var appID = "dQSoknSXZWaL1rQHVasgKnBhpiigcgHjuLgip8--m7w"
    var images = [JSON]()
    var imageViews = [UIImageView]()
    var imageCounter = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageViews = view.subviews.compactMap { $0 as? UIImageView }
        imageViews.forEach { $0.alpha = 0 }
        
        guard let url = URL(string: "https://api.unsplash.com/search/photos?client_id=\(appID)&query=\(category)&per_page=100") else {return}
        
        //        use of GCD
        DispatchQueue.global(qos: .userInteractive).async {
            fetch(url)
        }
        
        func fetch(_ url: URL){
            if let data = try? Data(contentsOf: url){
                let json = JSON(data)
                images = json["results"].arrayValue
                downloadImage()
            }
        }
    }
    
    func downloadImage() {
        //figure out what image to display
        let currentImage = images[imageCounter % images.count]
        
        //find its image url
        let imageName = currentImage["urls"]["full"].stringValue
        
        //add 1 to imagecounter so next time we load the following image
        imageCounter += 1
        
        //convert it to a swift url and download it
        guard let imageURL = URL(string: imageName) else { return }
        guard let imageData = try? Data(contentsOf: imageURL) else { return }
        
        //convert the data to a uiimage
        guard let image = UIImage(data: imageData) else { return }
        
        //push our work to the main thread
        DispatchQueue.main.async {
            
            //display it in the first image view
            self.show(image)
        }
    }
    
    func show(_ image: UIImage) {
        spinner.stopAnimating()
        
        //figure out which image view to activate and deactivate
        let imageViewToUse = imageViews[imageCounter % imageViews.count]
        let otherImageView = imageViews[(imageCounter + 1) % imageViews.count]
        
        //start an animation over two seconds
        UIView.animate(withDuration: 2.0, animations: {
            
            //make the image view use our images and alpha it upto 1
            imageViewToUse.image = image
            imageViewToUse.alpha = 1
            
            //move the deactivated image to the back, behind the activated one
            self.view.sendSubviewToBack(otherImageView)
        }) { _ in
            
            //crossfade finished
            otherImageView.alpha = 0
            otherImageView.transform = .identity
            
            
            UIView.animate(withDuration: 10.0, animations: {
                imageViewToUse.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { _ in
                DispatchQueue.global(qos: .userInteractive).async {
                    self.downloadImage()
                }
            }
        }
    }
}

