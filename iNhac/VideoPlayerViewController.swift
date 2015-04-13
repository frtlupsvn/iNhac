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
    
    
    var videoSource:VideoModel = VideoModel()
    
    var moviePlayer:MPMoviePlayerController!
    var dataSource:NSMutableArray = NSMutableArray()
    
    
    var segmentView: SMSegmentView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        var dataImage = NSData(contentsOfURL: NSURL(string: videoSource.PictureURL)!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        videoImage.image = UIImage(data: dataImage!)
        self.videoTitle.text = videoSource.Title
        self.videoArtist.text = videoSource.Artist
        self.videoView.text = String(videoSource.TotalView)
        
        
        //        ************************************
        //        ** Video Player ********************
        //        ************************************
        
        var url:NSURL = NSURL(string:videoSource.LinkDownload)!
        
        moviePlayer = MPMoviePlayerController(contentURL: url)
        moviePlayer.view.frame = CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: 197)
        
        self.view.addSubview(moviePlayer.view)
        moviePlayer.fullscreen = true
        
        moviePlayer.controlStyle = MPMovieControlStyle.Embedded
        
        //        ************************************
        //        ** // Video Player *****************
        //        ************************************
        

        /*
        Init SMsegmentView
        Use a Dictionary here to set its properties.
        Each property has its own default value, so you only need to specify for those you are interested.
        */
        self.segmentView = SMSegmentView(frame: CGRect(x:1, y:(64+197+1), width: self.view.frame.size.width-2, height: 40.0), separatorColour: UIColor(white: 0.95, alpha: 0.3), separatorWidth: 0.5, segmentProperties: [keySegmentTitleFont: UIFont.systemFontOfSize(12.0), keySegmentOnSelectionColour: UIColor(red: 245.0/255.0, green: 174.0/255.0, blue: 63.0/255.0, alpha: 1.0), keySegmentOffSelectionColour: UIColor.whiteColor(), keyContentVerticalMargin: 10.0])
        
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


        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.loadLyric()
            self.loadSingerInfo()
            self.loadOtherVideos()
        })
        
    }
    func loadOtherVideos(){
        //jsondata
        
        var jsonarray:NSMutableDictionary = NSMutableDictionary(object: "video", forKey: "t")
        jsonarray.setValue(videoSource.ArtistID, forKey: "id")
        
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
//                    
//                    var videoObject:VideoModel = VideoModel(myID: tempsObject["ID"] as NSString, myTitle: tempsObject["Title"]as NSString, myArtist: tempsObject["Artist"]as NSString,myArtistID:artistID, myTotalView: tempsObject["TotalView"]as Int, myGenre: tempsObject["Genre"]as NSString, myPictureURL: tempsObject["PictureURL"]as NSString, myLinkDownload: tempsObject["LinkDownload"]as NSString, myLinkPlayEmbed: tempsObject["LinkPlayEmbed"]as NSString, myLink: tempsObject["Link"]as NSString)
//                    
//                    self.dataSource.addObject(videoObject)
                    
                }
                
                self.tableView.reloadData()
                //                ********************************
                //                ** END *************************
                //                ********************************


            },
            failure: {
                (operation: AFHTTPRequestOperation!,error: NSError!) in println("Error:" + error.localizedDescription)
            }
        )
        //**************************************

    }
    func loadLyric(){
        //jsondata
        
        var jsonarray:NSMutableDictionary = NSMutableDictionary(object: "song", forKey: "t")
        jsonarray.setValue(videoSource.ID, forKey: "id")
        
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
                    self.videoLyric.text = results["Lyrics"] as String
                } else {
                    self.videoLyric.text = "Lời bài hát đang được cập nhật... \nCảm ơn"
                }
                
                //                ********************************
                //                ** END *************************
                //                ********************************
            },
            failure: {
                (operation: AFHTTPRequestOperation!,error: NSError!) in println("Error:" + error.localizedDescription)
            }
        )
        //**************************************

    }
    func loadSingerInfo(){
        //jsondata
        
        var jsonarray:NSMutableDictionary = NSMutableDictionary(object: "song", forKey: "t")
        jsonarray.setValue(videoSource.ArtistID, forKey: "id")
        
        var jsondata:NSString = (jsonarray.JSONString() as NSString)
            .base64EncodedStringWithWrapWidth(0)
            .stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            .URLEncodedString_ch()
        
        var signature:NSString = (jsondata as NSString).HMAC_MD5_WithSecretString(privateKey)
        
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html")
        
        //**************************************
        // CALL API
        
        var url = SINGER_INFO_API+"?publicKey="+publicKey+"&signature="+signature+"&jsondata="+jsondata
        println(url)
        
        manager.GET( url,
            parameters: nil,
            success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                //Success
                println("Singer info Successful")
                
                //                ********************************
                //                ** parse data to Object ********
                //                ********************************
                var results:NSDictionary = responseObject as NSDictionary
                
                self.nameArtist.text = results["ArtistName"] as NSString
                var tempString:String = results["Biography"] as String
                self.bioArtist.text = tempString.html2String
                
                var dataImage = NSData(contentsOfURL: NSURL(string: results["ArtistAvatar"] as NSString )!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                self.imageArtist.image = UIImage(data: dataImage!)
                
                //                ********************************
                //                ** END *************************
                //                ********************************
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
        let cell : VideoTableViewCell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath) as VideoTableViewCell
//        var videoObject:VideoModel = dataSource[indexPath.row] as VideoModel
//        cell.videoTitle.text = videoObject.Title
//        cell.artiseTitle.text = videoObject.Artist
//        
//        let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType!, imageURL: NSURL!) -> Void in
//        }
//        let url = NSURL(string:videoObject.PictureURL)!
//        
//        cell.videoImage.sd_setImageWithURL(url, completed: block)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
