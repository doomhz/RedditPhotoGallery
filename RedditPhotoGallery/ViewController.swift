//
//  ViewController.swift
//  RedditPhotoGallery
//
//  Created by Dumitru Glavan on 14/11/15.
//  Copyright © 2015 MakeitSolutions. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var redditImage: UIImageView!
    @IBOutlet weak var imageTitle: UILabel!

    var redditChannel = "awww"
    var imagePaths:[String] = []
    var imageTitles:[String] = []
    var currentImageIndex:Int = -1
    var redditUrl:String {
        return "http://reddit.com/r/" + redditChannel + "/hot.json?limit=100"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)

        loadImageList()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImageList() {
        let response = parseJSON(getJSON(redditUrl))!
        let items = response.objectForKey("data")?.objectForKey("children") as! [[String : AnyObject]]
        for item in items {
            if (item["data"]!["post_hint"]! != nil && item["data"]!["post_hint"] as! String == "image") {
                imagePaths.append(item["data"]!["url"] as! String)
                imageTitles.append(item["data"]!["title"] as! String)
            }
        }
        renderNextImage()
    }
    
    func renderNextImage() {
        currentImageIndex++
        if currentImageIndex >= imagePaths.count {
            currentImageIndex = 0
        }
        renderImage(imagePaths[currentImageIndex])
        renderTitle(imageTitles[currentImageIndex])
    }
    
    func renderPrevImage() {
        currentImageIndex--
        if currentImageIndex < 0 {
            currentImageIndex = imagePaths.count - 1
        }
        renderImage(imagePaths[currentImageIndex])
        renderTitle(imageTitles[currentImageIndex])
    }

    func getDataFromUrl(url:String, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url)!) { (data, response, error) in
            completion(data: NSData(data: data!))
            }.resume()
    }
    
    func calculateImageScaleRatio(width: CGFloat, height: CGFloat) -> [CGFloat] {
        let screenWidth:CGFloat = UIScreen.mainScreen().bounds.width
        let screenHeight:CGFloat = UIScreen.mainScreen().bounds.height
        var scaleWidth:CGFloat = 1
        var scaleHeight:CGFloat = 1
        if width > height {
            if screenWidth < width {
                scaleWidth = screenWidth * 100 / width / 100
                scaleHeight = scaleWidth
            }
        } else if width < height {
            if screenHeight < height {
                scaleHeight = screenHeight * 100 / height / 100
                scaleWidth = scaleHeight
            }
        }
        return [scaleWidth, scaleHeight]
    }
    
    func renderImage(url:String){
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                self.redditImage.contentMode = UIViewContentMode.TopLeft
                let image = UIImage(data: data!)
                let scaleRatio:[CGFloat] = self.calculateImageScaleRatio(image!.size.width, height: image!.size.height)
                let size = CGSizeApplyAffineTransform(image!.size, CGAffineTransformMakeScale(scaleRatio[0], scaleRatio[1]))
                let hasAlpha = false
                let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
                UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
                image!.drawInRect(CGRect(origin: CGPointZero, size: size))
                let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                self.redditImage.image = scaledImage
            }
        }
    }
    
    func renderTitle(title: String) {
        self.imageTitle.text = title
    }
    
    func getJSON(urlToRequest: String) -> NSData{
        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
    }
    
    func parseJSON(inputData: NSData) -> NSDictionary? {
        let boardsDictionary: NSDictionary
        do {
            try boardsDictionary = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        } catch {
            return nil
        }
        return boardsDictionary
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            renderPrevImage()
        }
        if (sender.direction == .Right) {
            renderNextImage()
        }
    }

}

