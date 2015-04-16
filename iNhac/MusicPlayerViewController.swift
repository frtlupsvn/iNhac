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
    
    var songSource:SongModel = SongModel()
//        var player = AVPlayer()
    var isPlay : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.songTitle.text = songSource.Title+" - "+songSource.Artist
        self.avaArtist.layer.cornerRadius = self.avaArtist.frame.size.width/2
        self.avaArtist.clipsToBounds = true
        
        pochette.layer.zPosition = 2
        diskView.layer.zPosition = 1
        kimVinyl.layer.zPosition = 3
        pochette.alpha = 1.0
        
        self.diskView.userInteractionEnabled = true
        var tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapOnDisk"))
        self.diskView.addGestureRecognizer(tapGesture)
        
        let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType!, imageURL: NSURL!) -> Void in
        }
        let url = NSURL(string:songSource.ArtistAvatar)!
        self.avaArtist.sd_setImageWithURL(url, completed: block)
        self.bufferSong(self.songSource.Link320)
        moveDisktoVinyl()
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
//            let url = url
//            let playerItem = AVPlayerItem( URL:NSURL( string:url ) )
//            player = AVPlayer(playerItem:playerItem)
//            player.rate = 1.0;
    }
    
    func playSong(){
        isPlay = true
        diskView.layer.speed = 1
//            player.play()
    }
    func pauseSong(){
        isPlay = false
        diskView.layer.speed = 0
//            player.pause()
    }
    func tapOnDisk(){
        if (self.isPlay == true){
            self.backKim()
        } else{
            self.rotateKim()
        }
    }
    
}
