//
//  VideoPlayerViewController.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 4/10/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

import UIKit
import MediaPlayer

let DETAIL_MINI_API = "http://api.mp3.zing.vn/api/detail-mini"
let SINGER_INFO_API = "http://api.mp3.zing.vn/api/singer-info"
let ARTIST_RELATE_API = "http://api.mp3.zing.vn/api/artist-relate"

class VideoPlayerViewController: UIViewController,SMSegmentViewDelegate,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoArtist: UILabel!
    @IBOutlet weak var videoView: UILabel!
    @IBOutlet weak var videoLyric: UITextView!
    @IBOutlet weak var lyricsView: UIView!
    @IBOutlet weak var singerInfo: SingerInfoView!
    @IBOutlet weak var imageArtist: UIImageView!
    @IBOutlet weak var nameArtist: UILabel!
    @IBOutlet weak var bioArtist: UITextView!
    @IBOutlet weak var artistRelate: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var minimizeButton: UIButton!
    
    @IBAction func minimize(sender: AnyObject) {
        // True is Min size , false is Max Size
        if(self.isMinimize == true) {
            // Min -> MAX
            self.minimizeButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
            self.minimizeButton.transform = CGAffineTransformRotate(self.minimizeButton.transform, CGFloat(M_PI)*90)
            UIView.animateWithDuration(0.9, animations: {
                self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                
                self.videoPlayer.view.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 197)
            })
        } else {
            // MAX -> Min
            self.minimizeButton.transform = CGAffineTransformMakeScale(0.5, 0.5)
            self.minimizeButton.transform = CGAffineTransformRotate(self.minimizeButton.transform, CGFloat(M_PI))
            UIView.animateWithDuration(0.9, animations: {
                self.view.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height-102, self.view.frame.size.width, self.view.frame.size.height)
                
              self.videoPlayer.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width/2 - 2, height: 100)
            })
        }
        isMinimize = !isMinimize
    }
    
    var lastLocation:CGPoint = CGPointMake(0,0)
    
    var videoSource:VideoModel = VideoModel()
    
    var videoPlayer:MPMoviePlayerController!
    
    var dataSource:NSMutableArray = NSMutableArray()
    
    
    var segmentView: SMSegmentView!
    
    var isMinimize: Bool!
    
    var swipeRight : UISwipeGestureRecognizer!
    
    var MyOwnerView : VideoHotViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeView:", name:"NotificationRemoveVideoPlayer", object: nil)
        //        ************************************
        //        ** Video Player ********************
        //        ************************************
        
        let url:NSURL = NSURL(string:videoSource.LinkDownload as String)!
        videoPlayer = MPMoviePlayerController(contentURL: url)
        videoPlayer.view.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 197)
        self.view.addSubview(videoPlayer.view)
        videoPlayer.fullscreen = true
        videoPlayer.controlStyle = MPMovieControlStyle.Embedded
        
        //        ************************************
        //        ** // Video Player *****************
        //        ************************************
        

        /*
        Init SMsegmentView
        Use a Dictionary here to set its properties.
        Each property has its own default value, so you only need to specify for those you are interested.
        */
        
        self.segmentView = SMSegmentView(frame: CGRect(x:0, y:(20+197+1), width: self.view.frame.size.width, height: 40.0), separatorColour: UIColor(white: 0.95, alpha: 0.3), separatorWidth: 0.5, segmentProperties: [keySegmentTitleFont: UIFont.systemFontOfSize(12.0), keySegmentOnSelectionColour: UIColor(red: 245.0/255.0, green: 174.0/255.0, blue: 63.0/255.0, alpha: 1.0), keySegmentOffSelectionColour: UIColor.whiteColor(), keyContentVerticalMargin: 10.0])
        
        self.segmentView.delegate = self
        
        self.segmentView.layer.cornerRadius = 0.0
        self.segmentView.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).CGColor
        self.segmentView.layer.borderWidth = 1.0
        
        // Add segments
        self.segmentView.addSegmentWithTitle("Lời Bài Hát", onSelectionImage: UIImage(named: "clip_light"), offSelectionImage: UIImage(named: "clip"))
        self.segmentView.addSegmentWithTitle("Thông Tin Ca Sĩ", onSelectionImage: UIImage(named: "bulb_light"), offSelectionImage: UIImage(named: "bulb"))
        self.segmentView.addSegmentWithTitle("Video Khác", onSelectionImage: UIImage(named: "cloud_light"), offSelectionImage: UIImage(named: "cloud"))
        
        // Set segment with index 0 as selected by default
        segmentView.selectSegmentAtIndex(0)
        self.view.addSubview(self.segmentView)

        
        
        // Minimize button Animation
        videoPlayer.view.addSubview(minimizeButton)
        isMinimize = false
        UIView.animateWithDuration(1.0, delay:0, options: [.Repeat, .Autoreverse, .AllowUserInteraction] , animations: {
            self.minimizeButton.frame = CGRect(x: self.minimizeButton.frame.origin.x, y: self.minimizeButton.frame.origin.y - 10, width: self.minimizeButton.frame.size.width, height: self.minimizeButton.frame.size.height)
            
            }, completion: nil)
        //****************************************************************************************
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.loadLyric()
            self.loadSingerInfo()
            self.loadOtherVideos()
        })
        
        //Set listeners for video maximize
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoFull"), name: "UIMoviePlayerControllerDidEnterFullscreenNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoMinimize"), name: "UIMoviePlayerControllerWillExitFullscreenNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoFull"), name: "MPMoviePlayerWillEnterFullscreenNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("videoMinimize"), name: "MPMoviePlayerWillExitFullscreenNotification", object: nil)
        
        // Gesture
        swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    func videoFull(){
        print("Full")
        self.view.hidden = true
    }
    
    func videoMinimize(){
        print("Min")
        self.view.hidden = false
    }
    
    func removeView(notification: NSNotification){
        //do stuff
        if (notification.name == "NotificationRemoveVideoPlayer" ){
            print("Notification Remove Video")
            if(self.isMinimize == true){
                UIView.animateWithDuration(0.9, animations: {
                    self.view.frame = CGRectMake(self.view.frame.size.width, self.view.frame.size.height-102, self.view.frame.size.width, self.view.frame.size.height)
                    self.view.alpha = 0
                    }, completion: {
                        (value: Bool) in
                        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NotificationRemoveVideoPlayer", object: nil)
                        self.MyOwnerView.removeVideoPlayer()
                        self.videoPlayer.stop()
                })
                
            }

        }
        
    }
    func removeMyObserver(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "NotificationRemoveVideoPlayer", object: nil)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                if(self.isMinimize == true){
                    UIView.animateWithDuration(0.9, animations: {
                        self.view.frame = CGRectMake(self.view.frame.size.width, self.view.frame.size.height-102, self.view.frame.size.width, self.view.frame.size.height)
                        self.view.alpha = 0
                        }, completion: {
                            (value: Bool) in
                            NSNotificationCenter.defaultCenter().removeObserver(self, name: "NotificationRemoveVideoPlayer", object: nil)
                            self.MyOwnerView.removeVideoPlayer()
                            self.videoPlayer.stop()
                    })
                
                }
            default:
                break
            }
        }
    }
    func stopVideo(){
        videoPlayer.stop()
    }
    func playVideo(withURL:NSString){
        let url:NSURL = NSURL(string:withURL as String)!
        videoPlayer.contentURL = url
        videoPlayer.play()
            }
    func loadOtherVideos(){
        //jsondata
        
        let jsonarray:NSMutableDictionary = NSMutableDictionary(object: "video", forKey: "t")
        jsonarray.setValue(videoSource.ArtistID, forKey: "id")
        
        let jsondata:NSString = (jsonarray.JSONString() as NSString)
            .base64EncodedStringWithWrapWidth(0)
            .stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            .URLEncodedString_ch()
        
        let signature:NSString = (jsondata as NSString).HMAC_MD5_WithSecretString(privateKey as String)
        
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as Set<NSObject>
        
        //**************************************
        // CALL API
        
        let url = "\(ARTIST_RELATE_API)?publicKey=\(publicKey)&signature=\(signature)&jsondata=\(jsondata)"

        manager.GET( url,
            parameters: nil,
            success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                //Success
                print("Singer relate Successful")
                //                ********************************
                //                ** parse data to Object ********
                //                ********************************
                let responseArray:NSArray = (responseObject as! NSDictionary).objectForKey("Data") as! NSArray
                for index in 0...responseArray.count-1{
                    let tempsObject:NSDictionary? = responseArray[index] as? NSDictionary
                    SwiftTryCatch.`try`({
                        let videoObject:VideoModel = VideoModel(myID: tempsObject?.objectForKey("ID") as! NSString, myTitle: tempsObject?.objectForKey("Title") as! NSString, myArtist: tempsObject?.objectForKey("Artist") as! NSString,myArtistID:"", myTotalView: tempsObject?.objectForKey("TotalView") as! Int, myGenre: tempsObject?.objectForKey("Genre") as! NSString, myPictureURL: tempsObject?.objectForKey("PictureURL") as! NSString, myLinkDownload: tempsObject?.objectForKey("LinkDownload") as! NSString, myLinkPlayEmbed: tempsObject?.objectForKey("LinkPlayEmbed")as! NSString, myLink:"")
                        self.dataSource.addObject(videoObject)

                        }, `catch`: { (error) in
                            print("\(error.description)")
                        }, finally: {
                            // close resources
                    })
                }
//
                self.tableView.reloadData()
//                //                ********************************
//                //                ** END *************************
//                //                ********************************


            },
            failure: {
                (operation: AFHTTPRequestOperation!,error: NSError!) in print("Error:" + error.localizedDescription)
            }
        )
        //**************************************

    }
    func loadLyric(){
        
        //jsondata
        
        let jsonarray:NSMutableDictionary = NSMutableDictionary(object: "song", forKey: "t")
        jsonarray.setValue(videoSource.ID, forKey: "id")
        
        let jsondata:NSString = (jsonarray.JSONString() as NSString)
            .base64EncodedStringWithWrapWidth(0)
            .stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            .URLEncodedString_ch()
        
        let signature:NSString = (jsondata as NSString).HMAC_MD5_WithSecretString(privateKey as String)
        
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as Set<NSObject>
        
        //**************************************
        // CALL API
        
        let url = "\(DETAIL_MINI_API)?publicKey=\(publicKey)&signature=\(signature)&jsondata=\(jsondata)"
        
        
        manager.GET( url,
            parameters: nil,
            success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                //Success
                print("Lyrics Successful")
                
                //                ********************************
                //                ** parse data to Object ********
                //                ********************************
                let results = responseObject as! NSDictionary
                let lyrics : NSString? = results["Lyrics"] as? NSString
                
                
                if(lyrics != nil){
                    self.videoLyric.text = results["Lyrics"] as! String
                } else {
                    self.videoLyric.text = "Lời bài hát đang được cập nhật... \nCảm ơn"
                }
                
                //                ********************************
                //                ** END *************************
                //                ********************************
            },
            failure: {
                (operation: AFHTTPRequestOperation!,error: NSError!) in print("Error:" + error.localizedDescription)
                self.videoLyric.text = "Lời bài hát đang được cập nhật... \nCảm ơn"
            }
        )
        //**************************************

        let urlImage = NSURL(string:videoSource.PictureURL as String)!
        videoImage.sd_setImageWithURL(urlImage)
        
        self.videoTitle.text = videoSource.Title as String
        self.videoArtist.text = videoSource.Artist as String
        self.videoView.text = String(videoSource.TotalView)
        
        self.lyricsView.setNeedsDisplay()

    }
    func loadSingerInfo(){
        //jsondata
        
        let jsonarray:NSMutableDictionary = NSMutableDictionary(object: "song", forKey: "t")
        jsonarray.setValue(videoSource.ArtistID, forKey: "id")
        
        let jsondata:NSString = (jsonarray.JSONString() as NSString)
            .base64EncodedStringWithWrapWidth(0)
            .stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            .URLEncodedString_ch()
        
        let signature:NSString = (jsondata as NSString).HMAC_MD5_WithSecretString(privateKey as String)
        
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as Set<NSObject>
        
        //**************************************
        // CALL API
        
        let url = "\(SINGER_INFO_API)?publicKey=\(publicKey)&signature=\(signature)&jsondata=\(jsondata)"
        
        manager.GET( url,
            parameters: nil,
            success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                //Success
                print("Singer info Successful")
                
                //                ********************************
                //                ** parse data to Object ********
                //                ********************************
                let results = responseObject as! NSDictionary
                
                self.nameArtist.text = results["ArtistName"] as? String
                let tempString:String = results["Biography"] as! String
                self.bioArtist.text = tempString.html2String
            

                let urlImage = NSURL(string:results["ArtistAvatar"] as! NSString as String)!
                self.imageArtist.sd_setImageWithURL(urlImage)
                
                //                ********************************
                //                ** END *************************
                //                ********************************
            },
            failure: {
                (operation: AFHTTPRequestOperation!,error: NSError!) in print("Error:" + error.localizedDescription)
            }
        )
        //**************************************
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
            self.singerInfo.hidden = true
            self.artistRelate.hidden = true
            break
        case  1:
            self.lyricsView.hidden = true
            self.singerInfo.hidden = false
            self.artistRelate.hidden = true
            break
        case  2:
            self.lyricsView.hidden = true
            self.singerInfo.hidden = true
            self.artistRelate.hidden = false
            break
        default:
            break
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : VideoTableViewCell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath) as! VideoTableViewCell
        let videoObject:VideoModel = dataSource[indexPath.row] as! VideoModel
        cell.videoTitle.text = videoObject.Title as String
        cell.artiseTitle.text = videoObject.Artist as String
        

        let url = NSURL(string:videoObject.PictureURL as String)!
        cell.videoImage.sd_setImageWithURL(url)
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.videoSource = dataSource[indexPath.row] as! VideoModel
        playVideo(videoSource.LinkDownload)
        loadLyric()
        segmentView.selectSegmentAtIndex(0)
        
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.clipsToBounds = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
