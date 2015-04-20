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
    
    var segmentView: SMSegmentView!
    
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
        self.albumMiniImage.sd_setImageWithURL(url, completed: block)
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
    
    func loadLyric(){
        //jsondata
        
        var jsonarray:NSMutableDictionary = NSMutableDictionary(object: "song", forKey: "t")
        jsonarray.setValue(songSource.ID, forKey: "id")
        
        var jsondata:NSString = (jsonarray.JSONString() as NSString)
            .base64EncodedStringWithWrapWidth(0)
            .stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            .URLEncodedString_ch()
        
        var signature:NSString = (jsondata as NSString).HMAC_MD5_WithSecretString(privateKey)
        
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html")
        
        //**************************************
        // CALL API
        
        var url = DETAIL_MINI_API+"?publicKey="+publicKey+"&signature="+signature+"&jsondata="+jsondata
        println(url)
        
        manager.GET( url,
            parameters: nil,
            success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                //Success
                println("Lyrics Successful")
                
                //                ********************************
                //                ** parse data to Object ********
                //                ********************************
                var results:NSDictionary = responseObject as NSDictionary
                var lyrics : NSString? = results["Lyrics"] as? NSString
                
                
                if(lyrics != nil){
                    self.songLyrics.text = results["Lyrics"] as String
                } else {
                    self.songLyrics.text = "Lời bài hát đang được cập nhật... \nCảm ơn"
                }
                
                //                ********************************
                //                ** END *************************
                //                ********************************
            },
            failure: {
                (operation: AFHTTPRequestOperation!,error: NSError!) in println("Error:" + error.localizedDescription)
                self.songLyrics.text = "Lời bài hát đang được cập nhật... \nCảm ơn"
            }
        )
        //**************************************
        self.songLyrics.setNeedsDisplay()
        
    }
    
    func loadSongRelate(){
        //jsondata
        
        var jsonarray:NSMutableDictionary = NSMutableDictionary(object: "song", forKey: "t")
        jsonarray.setValue(songSource.ArtistID, forKey: "id")
        
        var jsondata:NSString = (jsonarray.JSONString() as NSString)
            .base64EncodedStringWithWrapWidth(0)
            .stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            .URLEncodedString_ch()
        
        var signature:NSString = (jsondata as NSString).HMAC_MD5_WithSecretString(privateKey)
        
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html")
        
        //**************************************
        // CALL API
        
        var url = ARTIST_RELATE_API+"?publicKey="+publicKey+"&signature="+signature+"&jsondata="+jsondata
        println(url)
        
        manager.GET( url,
            parameters: nil,
            success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                //Success
                println("Singer relate Successful")
                //                ********************************
                //                ** parse data to Object ********
                //                ********************************
                var responseArray:NSArray = (responseObject as NSDictionary).objectForKey("Data") as NSArray
                for index in 0...responseArray.count-1{
                    
 
                        var tempsObject:NSDictionary = responseArray[index] as NSDictionary

                        
                        var songObject:SongModel = SongModel(myID: tempsObject["ID"] as NSString, myTitle: tempsObject["Title"] as NSString, myArtist: self.songSource.Artist, myArtistID: "", myComposer: "", myTotalListen: 0, myGenre: "", myArtistAvatar: "", myLinkPlayEmbed: tempsObject["LinkPlayEmbed"] as NSString, myLink128: tempsObject["LinkPlay128"] as NSString, myLink320: tempsObject["LinkPlay320"] as NSString, myLink: tempsObject["Link"] as NSString)
                    
                        self.dataSource.addObject(songObject)

                        

                }
                //
                self.tableView.reloadData()
                //                //                ********************************
                //                //                ** END *************************
                //                //                ********************************
                
                
            },
            failure: {
                (operation: AFHTTPRequestOperation!,error: NSError!) in println("Error:" + error.localizedDescription)
            }
        )
        //**************************************
        
    }

    // SMSegment Delegate
    func didSelectSegmentAtIndex(segmentIndex: Int) {
        /*
        Replace the following line to implement what you want the app to do after the segment gets tapped.
        */
        println("Select segment at index: \(segmentIndex)")
        
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
        
        
        var duration :CMTime = self.player.currentItem.asset.duration
        var second : Float64 = CMTimeGetSeconds(duration) as Float64
        println(secondsToHoursMinutesSeconds(Int(second)))
        
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

        if ((self.timer.value != endSecond) & (self.isPlay)){
            var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimer:"), userInfo: nil, repeats: false)
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
    
    
    // MARK: - TableView
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : SongTableViewCell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath) as SongTableViewCell
        var videoObject:SongModel = dataSource[indexPath.row] as SongModel
        cell.sttLabel.text = String(indexPath.row)
        cell.songTitle.text = videoObject.Title
        cell.singerLabel.text = videoObject.Artist
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    }
    
    
}
