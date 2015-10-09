//
//  MusicPlayerViewController.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 4/15/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia

class MusicPlayerViewController: UIViewController,SMSegmentViewDelegate,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var timer: UISlider!
    
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var startTime: UILabel!
    
    @IBOutlet weak var songLyrics: UITextView!
    
    @IBOutlet weak var songRelaveView: UIView!
    @IBOutlet weak var lyricsView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    var dataSource:NSMutableArray = NSMutableArray()
    
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
                self.playView.alpha = 1
                self.playView.hidden = false
                self.miniView.hidden = true
            })
        } else {
            // MAX -> Min
            UIView.animateWithDuration(0.9, animations: {
                self.view.frame = CGRectMake(0, self.view.frame.size.height-30, self.view.frame.size.width, self.view.frame.size.height)
                self.miniView.hidden = false
                self.playView.alpha = 0
                }, completion: {
                    (value:Bool) in
                    self.minimizeButton.hidden = true
                    self.playView.hidden = true
                    
            })
        }
        isMinimize = !isMinimize
        
    }
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var miniView: UIView!
    @IBOutlet weak var albumMiniImage: UIImageView!
    
    @IBOutlet weak var songTitleMini: UILabel!
    
    var isMinimize: Bool!
    var swipeRight : UISwipeGestureRecognizer!
    
    var songSource:SongModel = SongModel()
    var player = AVPlayer()
    var isPlay : Bool!
    var MyOwnerView : SongHotViewController!
    var Mytimer : NSTimer!
    var segmentView: SMSegmentView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeView:", name:"NotificationRemoveSongPlayer", object: nil)
        
        // Do any additional setup after loading the view.
        self.view.tag = 200
        self.songTitle.text = (songSource.Title as String)+" - "+(songSource.Artist as String)
        self.songTitleMini.text = self.songTitle.text
        self.avaArtist.layer.cornerRadius = self.avaArtist.frame.size.width/2
        self.avaArtist.clipsToBounds = true
        
        pochette.layer.zPosition = 2
        diskView.layer.zPosition = 1
        kimVinyl.layer.zPosition = 3
        pochette.alpha = 1.0
        
        self.diskView.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("tapOnDisk"))
        self.diskView.addGestureRecognizer(tapGesture)
        
        self.miniView.userInteractionEnabled = true
        let miniViewTap = UITapGestureRecognizer(target: self, action: Selector("minimizeAction:"))
        self.miniView.addGestureRecognizer(miniViewTap)
        
        
        
        self.bufferSong(self.songSource.Link320)
        moveDisktoVinyl()
        
        // Minimize button Animation
        isMinimize = false
        miniView.hidden = true
        UIView.animateWithDuration(1.0, delay:0, options: [.Repeat, .Autoreverse, .AllowUserInteraction] , animations: {
            self.minimizeButton.frame = CGRect(x: self.minimizeButton.frame.origin.x, y: self.minimizeButton.frame.origin.y - 10, width: self.minimizeButton.frame.size.width, height: self.minimizeButton.frame.size.height)
            }, completion: nil)
        //****************************************************************************************
        
        // Gesture
        swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.miniView.addGestureRecognizer(swipeRight)
        
        /*
        Init SMsegmentView
        Use a Dictionary here to set its properties.
        Each property has its own default value, so you only need to specify for those you are interested.
        */
        
        self.segmentView = SMSegmentView(frame: CGRect(x:0, y:280, width: self.view.frame.size.width, height: 40.0), separatorColour: UIColor(white: 0.95, alpha: 0.3), separatorWidth: 0.5, segmentProperties: [keySegmentTitleFont: UIFont.systemFontOfSize(12.0), keySegmentOnSelectionColour: UIColor(red: 245.0/255.0, green: 174.0/255.0, blue: 63.0/255.0, alpha: 1.0), keySegmentOffSelectionColour: UIColor.whiteColor(), keyContentVerticalMargin: 10.0])
        
        self.segmentView.delegate = self
        
        self.segmentView.layer.cornerRadius = 0.0
        self.segmentView.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).CGColor
        self.segmentView.layer.borderWidth = 1.0
        
        // Add segments
        self.segmentView.addSegmentWithTitle("Lời Bài Hát", onSelectionImage: UIImage(named: "clip_light"), offSelectionImage: UIImage(named: "clip"))
        self.segmentView.addSegmentWithTitle("Bài Hát Khác", onSelectionImage: UIImage(named: "bulb_light"), offSelectionImage: UIImage(named: "bulb"))
        
        // Set segment with index 0 as selected by default
        segmentView.selectSegmentAtIndex(0)
        self.view.addSubview(self.segmentView)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.loadLyric()
            self.loadSongRelate()
        })
        
        
    }
    
    
    // SMSegment Delegate
    func didSelectSegmentAtIndex(segmentIndex: Int) {
        /*
        Replace the following line to implement what you want the app to do after the segment gets tapped.
        */
        print("Select segment at index: \(segmentIndex)")
        
        switch segmentIndex {
        case  0:
            self.lyricsView.hidden = false
            self.songRelaveView.hidden = true
            break
        case  1:
            self.lyricsView.hidden = true
            self.songRelaveView.hidden = false
            break
        default:
            break
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(animated: Bool) {
    }
    
    
    // MARK: - Song Player
    func bufferSong(url:NSString) {
        
        let urlImage = NSURL(string:songSource.ArtistAvatar as String)!
        self.avaArtist.sd_setImageWithURL(urlImage)
        self.albumMiniImage.sd_setImageWithURL(urlImage)
        let urlSong = url
        let playerItem = AVPlayerItem( URL:NSURL( string:urlSong as String )! )
        player = AVPlayer(playerItem:playerItem)
        
        let duration :CMTime = self.player.currentItem!.asset.duration
        var second : Float64 = CMTimeGetSeconds(duration) as Float64
        print(secondsToHoursMinutesSeconds(Int(second)))
        
        self.timer.minimumValue = 0
        self.timer.maximumValue = Float(second)
        
        let (h,m,s) = secondsToHoursMinutesSeconds(Int(second))
        if ( (h) == 0 ){
            ((s) > 9) ? (self.endTime.text = ("\(m):\(s)") ) : ( self.endTime.text = ("\(m):0\(s)") )
        } else {
            (self.endTime.text = ("\(h):\(m):\(s)") )
        }
        
    }
    
    func playSong(){
        isPlay = true
        diskView.layer.speed = 1
        player.play()
        if(self.player.rate == 1){
            updateTimer(self.timer.maximumValue)
        }
    }
    func updateTimer(endSecond:Float){
        self.timer.value++
        let (h,m,s) = secondsToHoursMinutesSeconds(Int(self.timer.value))
        if ( (h) == 0 ){
            ((s) > 9) ? (self.startTime.text = ("\(m):\(s)") ) : ( self.startTime.text = ("\(m):0\(s)") )
        } else {
            (self.startTime.text = ("\(h):\(m):\(s)") )
        }
        
        if ( (self.timer.value != endSecond) ){
            Mytimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimer:"), userInfo: nil, repeats: false)
        }
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
            print("Notification Remove Song")
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
    
    func resetTimer(){
        self.timer.value = 0
    }
    func removeMyObserver(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NotificationRemoveSongPlayer", object: nil)
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
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    
    
    
}
