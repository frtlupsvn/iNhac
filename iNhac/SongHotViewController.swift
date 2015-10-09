//
//  SongHotViewController.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 4/9/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

import UIKit

class SongHotViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    var dataSource:NSMutableArray = NSMutableArray()
    var songPlayer:MusicPlayerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func removeSongPlayer(){
        print("Song destroyed")
        self.songPlayer.view.removeFromSuperview()
        self.songPlayer.pauseSong()
        self.songPlayer.removeMyObserver()
        self.songPlayer = nil
    }

    
    // MARK: - TableView
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : SongTableViewCell = tableView.dequeueReusableCellWithIdentifier("songCell", forIndexPath: indexPath) as! SongTableViewCell
        let videoObject:SongModel = dataSource[indexPath.row] as! SongModel
        cell.sttLabel.text = String(indexPath.row)
        cell.songTitle.text = videoObject.Title as String
        cell.singerLabel.text = videoObject.Artist as String
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (self.songPlayer == nil){
            showSongPlayer(dataSource[indexPath.row] as! SongModel)
        } else {
          removeSongPlayer()
          showSongPlayer(dataSource[indexPath.row] as! SongModel)
        }
        
    }
    
    func showSongPlayer(songSource:SongModel){
        
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationRemoveVideoPlayer", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("NotificationRemoveSongPlayer", object: nil)

        // Create video player view with animation from right-bot with alpha 0 and expand to full screen
        // Amazing code -))
        
        self.songPlayer = self.storyboard?.instantiateViewControllerWithIdentifier("SongPlayer")
            as! MusicPlayerViewController
        self.songPlayer.songSource = songSource
        self.songPlayer.MyOwnerView = self
        self.songPlayer.view.frame = CGRectMake(self.view.frame.size.width-50, self.view.frame.size.height-50, self.view.frame.size.width, self.view.frame.size.height)
        self.songPlayer.view.alpha = 0
        self.songPlayer.view.transform = CGAffineTransformMakeScale(0.2, 0.2)
        
        UIApplication.sharedApplication().keyWindow?.addSubview(self.songPlayer.view)
        
        UIView.animateWithDuration(0.9, animations: {
            self.songPlayer.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            self.songPlayer.view.alpha = 1
            self.songPlayer.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)
        })
        
        //      ************************************************************************************************
        //      ************************************************************************************************
        
    }
}
