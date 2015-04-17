//
//  MusicPlayerViewController.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 4/15/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController {
    
    @IBOutlet weak var timer: UISlider!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var avaArtist: UIImageView!
    @IBOutlet weak var vinylImage: UIImageView!
    @IBOutlet weak var kimVinyl: UIImageView!
    @IBOutlet weak var pochette: UIImageView!
    @IBOutlet weak var diskView: UIView!
    @IBOutlet weak var minimizeButton: UIButton!
    @IBAction func minimizeAction(sender: AnyObject) {
        
        // True is Min size , false is Max Size
        if(self.isMinimize == true) {
            // Min -> MAX
            self.minimizeButton.hidden = false
            UIView.animateWithDuration(0.9, animations: {
                self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                self.playView.hidden = false
                self.miniView.hidden = true
                            })
        } else {
            // MAX -> Min
            self.minimizeButton.hidden = true
            UIView.animateWithDuration(0.9, animations: {
                self.view.frame = CGRectMake(0, self.view.frame.size.height-30, self.view.frame.size.width, self.view.frame.size.height)
                self.playView.hidden = true
                self.miniView.hidden = false
            })
        }
        isMinimize = !isMinimize

    }
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var miniView: UIView!
    
    @IBOutlet weak var songTitleMini: UILabel!
    
    var isMinimize: Bool!
    var swipeRight : UISwipeGestureRecognizer!
    
    var songSource:SongModel = SongModel()
        var player = AVPlayer()
    var isPlay : Bool!
    var MyOwnerView : SongHotViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeView:", name:"NotificationRemoveSongPlayer", object: nil)
        
        // Do any additional setup after loading the view.
        self.view.tag = 200
        self.songTitle.text = songSource.Title+" - "+songSource.Artist
        self.songTitleMini.text = self.songTitle.text
        self.avaArtist.layer.cornerRadius = self.avaArtist.frame.size.width/2
        self.avaArtist.clipsToBounds = true
        
        pochette.layer.zPosition = 2
        diskView.layer.zPosition = 1
        kimVinyl.layer.zPosition = 3
        pochette.alpha = 1.0
        
        self.diskView.userInteractionEnabled = true
        var tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapOnDisk"))
        self.diskView.addGestureRecognizer(tapGesture)
        
        self.miniView.userInteractionEnabled = true
        var miniViewTap = UITapGestureRecognizer(target: self, action: Selector("minimizeAction:"))
        self.miniView.addGestureRecognizer(miniViewTap)
        
        let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType!, imageURL: NSURL!) -> Void in
        }
        let url = NSURL(string:songSource.ArtistAvatar)!
        self.avaArtist.sd_setImageWithURL(url, completed: block)
        self.bufferSong(self.songSource.Link320)
        moveDisktoVinyl()
        
        // Minimize button Animation
        isMinimize = false
        miniView.hidden = true
        UIView.animateWithDuration(1.0, delay:0, options: .Repeat | .Autoreverse | .AllowUserInteraction , animations: {
            self.minimizeButton.frame = CGRect(x: self.minimizeButton.frame.origin.x, y: self.minimizeButton.frame.origin.y - 10, width: self.minimizeButton.frame.size.width, height: self.minimizeButton.frame.size.height)
            }, completion: nil)
        //****************************************************************************************
        
        // Gesture
        swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.miniView.addGestureRecognizer(swipeRight)


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(animated: Bool) {
    }
    
    
    // MARK: - Rotation
    
    func moveDisktoVinyl(){
        self.diskView.transform = CGAffineTransformMakeScale(1.05, 1.05)
        let duration = 2.0
        let delay = 0.0
        let options = UIViewAnimationOptions.CurveLinear
        UIView.animateWithDuration(duration, delay: delay, options: nil, animations: {
            self.diskView.frame.origin.x = self.view.frame.size.width * 0.9

            }, completion:{
                (value:Bool) in
                UIView.animateWithDuration(0.5, delay: 0.2, options:.CurveEaseInOut, animations: {
                                        self.pochette.frame = CGRectMake(self.pochette.frame.origin.x - 500, self.pochette.frame.origin.y, self.pochette.frame.size.width, self.pochette.frame.size.height)
                    }, completion: {
                       (value:Bool) in
                        self.pochette.removeFromSuperview()
                })
                self.diskView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.rotateDisk()
                self.rotateKim()
                
        })

    }
    func rotateKim(){
        let duration = 1.0
        let delay = 0.0
        let options = UIViewAnimationOptions.CurveLinear
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
            self.kimVinyl.transform = CGAffineTransformRotate(self.kimVinyl.transform,CGFloat(M_PI)/4)
            }, completion:{
                (value:Bool)in
                self.playSong()
        })
    }
    func backKim(){
        self.pauseSong()
        let duration = 1.0
        let delay = 0.0
        let options = UIViewAnimationOptions.CurveLinear
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
            self.kimVinyl.transform = CGAffineTransformRotate(self.kimVinyl.transform,-CGFloat(M_PI)/4)
            }, completion:{
                (value:Bool)in
                
        })

    }
    
    func rotateDisk(){
        let duration = 2.0
        let delay = 0.0
        let options = UIViewAnimationOptions.CurveLinear | .AllowUserInteraction
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
            self.diskView.transform = CGAffineTransformRotate(self.diskView.transform,CGFloat(M_PI))
            }, completion:{
                (value:Bool) in
                self.rotateDisk()
        })
    }
    
    // MARK: - Song Player
    func bufferSong(url:NSString) {
            let url = url
            let playerItem = AVPlayerItem( URL:NSURL( string:url ) )
            player = AVPlayer(playerItem:playerItem)
            player.rate = 1.0;
    }
    
    func playSong(){
        isPlay = true
        diskView.layer.speed = 1
            player.play()
    }
    func pauseSong(){
        isPlay = false
        diskView.layer.speed = 0
            player.pause()
    }
    func tapOnDisk(){
        if (self.isPlay == true){
            self.backKim()
        } else{
            self.rotateKim()
        }
    }
    
    func removeView(notification: NSNotification){
        //do stuff
        if (notification.name == "NotificationRemoveSongPlayer"){
            println("Notification Remove Song")
            if(self.isMinimize == true){
                UIView.animateWithDuration(0.9, animations: {
                    self.view.frame = CGRectMake(self.view.frame.size.width, self.view.frame.size.height-30, self.view.frame.size.width, self.view.frame.size.height)
                    self.view.alpha = 0
                    }, completion: {
                        (value: Bool) in
                        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NotificationRemoveSongPlayer", object: nil)
                        self.MyOwnerView.removeSongPlayer()
                        self.player.pause()
                })
                
            }
        }
        
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                if(self.isMinimize == true){
                    UIView.animateWithDuration(0.9, animations: {
                        self.view.frame = CGRectMake(self.view.frame.size.width, self.view.frame.size.height-30, self.view.frame.size.width, self.view.frame.size.height)
                        self.view.alpha = 0
                        }, completion: {
                            (value: Bool) in
                                NSNotificationCenter.defaultCenter().removeObserver(self, name: "NotificationRemoveSongPlayer", object: nil)
                                self.MyOwnerView.removeSongPlayer()
                                self.player.pause()
                    })
                    
                }
            default:
                break
            }
        }
    }

    
}
