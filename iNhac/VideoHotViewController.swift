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
        self.performSegueWithIdentifier("pushVideoPlayer", sender: dataSource[indexPath.row] as VideoModel)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "pushVideoPlayer") {
            let videoPlayerControl = segue.destinationViewController as VideoPlayerViewController
            videoPlayerControl.videoSource = sender as VideoModel
        }
    }
}
