//
//  VideoHotViewController.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 4/9/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

import UIKit

class VideoHotViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    var dataSource:NSMutableArray = NSMutableArray()
    
//    var videoPlayer:VideoPlayerViewController!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : VideoTableViewCell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath) as VideoTableViewCell
        var videoObject:VideoModel = dataSource[indexPath.row] as VideoModel
        cell.videoTitle.text = videoObject.Title
        cell.artiseTitle.text = videoObject.Artist
        
        let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType!, imageURL: NSURL!) -> Void in
        }
        let url = NSURL(string:videoObject.PictureURL)!
        
        cell.videoImage.sd_setImageWithURL(url, completed: block)
        
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        self.performSegueWithIdentifier("pushVideoPlayer", sender: dataSource[indexPath.row] as VideoModel)
//        
//        self.videoPlayer = self.storyboard?.instantiateViewControllerWithIdentifier("VideoPlayer")
//         as VideoPlayerViewController
//        self.videoPlayer.videoSource = dataSource[indexPath.row] as VideoModel
//        self.videoPlayer.view.frame = CGRectMake(self.view.frame.size.width-50, self.view.frame.size.height-50, self.view.frame.size.width, self.view.frame.size.height)
//        self.videoPlayer.view.alpha = 0
//        self.videoPlayer.view.transform = CGAffineTransformMakeScale(0.2, 0.2)
//        
//       UIApplication.sharedApplication().keyWindow?.addSubview(self.videoPlayer.view)
////        self.videoPlayer.onView = self.view
//        
//        UIView.animateWithDuration(0.9, animations: {
//            self.videoPlayer.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
//            self.videoPlayer.view.alpha = 1
//            self.videoPlayer.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)
//        })
    }
}
