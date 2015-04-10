//
//  VideoPlayerViewController.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 4/10/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

import UIKit
import MediaPlayer

let DETAIL_MINI_API = "http://api.mp3.zing.vn/api/hot-content"

class VideoPlayerViewController: UIViewController {
    
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoArtist: UILabel!
    @IBOutlet weak var videoView: UILabel!
    @IBOutlet weak var videoLyric: UITextView!
    
    
    
    var videoSource:VideoModel = VideoModel()
    var moviePlayer:MPMoviePlayerController!
    
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            //All stuff here
            self.loadLyric()
        })
    }
    
    func loadLyric(){
        //jsondata
        
        var jsonarray:NSMutableDictionary = NSMutableDictionary(object: "video", forKey: "t")
        
        
        var jsondata:NSString = (jsonarray.JSONString() as NSString)
            .base64EncodedStringWithWrapWidth(0)
            .stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            .URLEncodedString_ch()
        
        var signature:NSString = (jsondata as NSString).HMAC_MD5_WithSecretString(privateKey)
        
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html")
        
        //**************************************
        // CALL API
        
        var url = HOT_CONTENT_API+"?publicKey="+publicKey+"&signature="+signature+"&jsondata="+jsondata
        println(url)
        
        manager.GET( url,
            parameters: nil,
            success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                //Success
                println("Video Successful")
                
                //                ********************************
                //                ** parse data to Object ********
                //                ********************************
                var responseArray:NSArray = responseObject as NSArray
                
                for index in 0...responseArray.count-1{
                    var tempsObject:NSDictionary = responseArray[index] as NSDictionary
                    var videoObject:VideoModel = VideoModel(myID: tempsObject["ID"] as NSString, myTitle: tempsObject["Title"]as NSString, myArtist: tempsObject["Artist"]as NSString, myTotalView: tempsObject["TotalView"]as Int, myGenre: tempsObject["Genre"]as NSString, myPictureURL: tempsObject["PictureURL"]as NSString, myLinkDownload: tempsObject["LinkDownload"]as NSString, myLinkPlayEmbed: tempsObject["LinkPlayEmbed"]as NSString, myLink: tempsObject["Link"]as NSString)
                    
                    self.videoData.addObject(videoObject)
                    
                }
                //                ********************************
                //                ** END *************************
                //                ********************************
                
                
                
                
                var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("getSongHotContent"), userInfo: nil, repeats: false)
                
            },
            failure: {
                (operation: AFHTTPRequestOperation!,error: NSError!) in println("Error:" + error.localizedDescription)
            }
        )
        //**************************************

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
