//
//  ViewController.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 3/31/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

//Trang home sẽ load bảng xếp hạng nhạc của: VIỆTNAM, ÂU MỸ, HÀNQUỐC

import UIKit

let HOT_CONTENT_API = "http://api.mp3.zing.vn/api/hot-content"

let publicKey:NSString = "4c3d549977f7943bd9cc6d33f656bb5c1c87d2c0"
let privateKey:NSString = "c9c2a7f66b677012b763512da77040b3"

class HomeController: UIViewController , UITableViewDataSource, UITableViewDelegate, FeSpinnerTenDotDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var imageSource = NSMutableArray()
    var titleSource = NSMutableArray()
    
    var videoData = NSMutableArray()
    var songData =  NSMutableArray()
    var albumData = NSMutableArray()
    
    var arrTitleLoading = NSArray()
    var index = NSInteger()
    var spinner = FeSpinnerTenDot()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set background color
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.topItem?.title = "NHẠC HOT"
        self.navigationController?.navigationBarHidden = true
        
        imageSource.addObject("1.jpg")
        imageSource.addObject("2.jpg")
        imageSource.addObject("3.jpg")
        
        titleSource.addObject("HOT VIDEOS")
        titleSource.addObject("HOT SONGS")
        titleSource.addObject("HOT ALBUMS")
        
        //**************************************
        index = 0
        self.arrTitleLoading = ["LOADING","LOADING VIDEO LIST","LOADING SONG LIST","LOADING ALBUM HOT","SUCCESSFUL"]
        // init Loader
        
        self.spinner = FeSpinnerTenDot(view: self.view, withBlur: true)
        self.spinner.backgroundColor = UIColor(hexCode: "#019875")
        self.spinner.titleLabelText = self.arrTitleLoading[self.index] as NSString
        self.spinner.fontTitleLabel = UIFont(name: "Neou-Thin", size: 36)
        self.view.addSubview(spinner)
        
        self.spinner.delegate = self
        self.spinner.show()
        
        //**************************************
        
        
        //Connect to Zing API
        getVideoHotContent()
    }
    
    func getVideoHotContent(){
        
        //"LOADING VIDEO LIST"
        self.index++
        self.spinner.titleLabelText = self.arrTitleLoading[self.index] as NSString
        
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
                    var artistDetail : NSArray = tempsObject["ArtistDetail"] as NSArray
                    var artistID : NSString = (artistDetail[0] as NSDictionary).objectForKey("ArtistID") as NSString
                    
                    var videoObject:VideoModel = VideoModel(myID: tempsObject["ID"] as NSString, myTitle: tempsObject["Title"]as NSString, myArtist: tempsObject["Artist"]as NSString,myArtistID:artistID, myTotalView: tempsObject["TotalView"]as Int, myGenre: tempsObject["Genre"]as NSString, myPictureURL: tempsObject["PictureURL"]as NSString, myLinkDownload: tempsObject["LinkDownload"]as NSString, myLinkPlayEmbed: tempsObject["LinkPlayEmbed"]as NSString, myLink: tempsObject["Link"]as NSString)
                    
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
    
    func getSongHotContent(){
        
        //"LOADING SONG LIST"
        self.index++
        self.spinner.titleLabelText = self.arrTitleLoading[self.index] as NSString
        
        //jsondata
        
        
        var jsonarray:NSMutableDictionary = NSMutableDictionary()
        jsonarray.setValue("song", forKey: "t")
        
        
        
        var jsondata:NSString = (jsonarray.JSONString() as NSString)
            .base64EncodedStringWithWrapWidth(0)
            .stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            .URLEncodedString_ch()
        var signature:NSString = (jsondata as NSString).HMAC_MD5_WithSecretString(privateKey)
        
        //        println(jsondata)
        //        println(signature)
        
        
        //**************************************
        // CALL API
        
        var url = HOT_CONTENT_API+"?publicKey="+publicKey+"&signature="+signature+"&jsondata="+jsondata
        
        println(url)
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html")
        
        manager.GET( url,
            parameters: nil,
            success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                println("Song Successful")
                //                ********************************
                //                ** parse data to Object ********
                //                ********************************
                var responseArray:NSArray = responseObject as NSArray
                
                for index in 0...responseArray.count-1{
                    
                    var tempsObject:NSDictionary = responseArray[index] as NSDictionary
                    var artistDetail : NSArray = tempsObject["ArtistDetail"] as NSArray
                    
                    var artistID : Int = (artistDetail[0] as NSDictionary).objectForKey("ArtistID") as Int
                    var artistAvatar:NSString = (artistDetail[0] as NSDictionary).objectForKey("ArtistAvatar") as NSString
                    
                    var songObject:SongModel = SongModel(myID: tempsObject["ID"] as NSString, myTitle: tempsObject["Title"] as NSString, myArtist: tempsObject["Artist"] as NSString, myArtistID: String(artistID), myComposer: tempsObject["Composer"] as NSString, myTotalListen: tempsObject["TotalListen"] as Int, myGenre: tempsObject["Genre"] as NSString, myArtistAvatar: artistAvatar, myLinkPlayEmbed: tempsObject["LinkPlayEmbed"] as NSString, myLink128: tempsObject["LinkPlay128"] as NSString, myLink320: tempsObject["LinkPlay320"] as NSString, myLink: tempsObject["Link"] as NSString)
                    self.songData.addObject(songObject)
                    
                }
                //                ********************************
                //                ** END *************************
                //                ********************************

                var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("getAlbumHotContent"), userInfo: nil, repeats: false)
            },
            failure: {
                (operation: AFHTTPRequestOperation!,error: NSError!) in println("Error:" + error.localizedDescription)
            }
        )
        
        //**************************************
    }
    
    func getAlbumHotContent(){
        //"LOADING SONG LIST"
        self.index++
        self.spinner.titleLabelText = self.arrTitleLoading[self.index] as NSString
        
        //jsondata
        
        
        var jsonarray:NSMutableDictionary = NSMutableDictionary()
        jsonarray.setValue("album", forKey: "t")
        
        
        
        var jsondata:NSString = (jsonarray.JSONString() as NSString)
            .base64EncodedStringWithWrapWidth(0)
            .stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            .URLEncodedString_ch()
        var signature:NSString = (jsondata as NSString).HMAC_MD5_WithSecretString(privateKey)
        
        //        println(jsondata)
        //        println(signature)
        
        
        //**************************************
        // CALL API
        
        var url = HOT_CONTENT_API+"?publicKey="+publicKey+"&signature="+signature+"&jsondata="+jsondata
        
        println(url)
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html")
        
        manager.GET( url,
            parameters: nil,
            success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                println("Album Successful")
                var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("backToView"), userInfo: nil, repeats: false)
            },
            failure: {
                (operation: AFHTTPRequestOperation!,error: NSError!) in println("Error:" + error.localizedDescription)
            }
        )
        
        //**************************************
        
    }
    
    func backToView(){
        self.spinner.dismiss()
        self.navigationController?.navigationBarHidden = false
        
        //**************************************
        // Media Player
//        addMediaPlayer()
        //**************************************
        
    }
    
    func addMediaPlayer(){
        //**************************************
        // Media Player
        var playerTabbar = PlayerView(frame: CGRectMake(0, self.view.frame.height-120, self.view.frame.width, 120))
        playerTabbar.layer.zPosition = 1
        UIApplication.sharedApplication().keyWindow?.addSubview(playerTabbar)
        //**************************************
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : homepageCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as homepageCell
        
        cell.labelHome.text = titleSource[indexPath.row] as NSString
        cell.imageHome.image = UIImage(named: imageSource.objectAtIndex(indexPath.row) as NSString)
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.layer.borderWidth = 1
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
        case  0:
            self.performSegueWithIdentifier("pushVideoView", sender: nil)
            break
        case  1:
            self.performSegueWithIdentifier("pushSongView", sender: nil)
            break
        case  2:
            self.performSegueWithIdentifier("pushAlbumView", sender: nil)
            break
        default:
            break
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleSource.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "pushVideoView") {
            let videoViewControl = segue.destinationViewController as VideoHotViewController
            videoViewControl.dataSource = videoData
        }
        if (segue.identifier == "pushSongView") {
            let songViewControl = segue.destinationViewController as SongHotViewController
            songViewControl.dataSource = songData
        }
        if (segue.identifier == "pushAlbumView") {
            let albumViewControl = segue.destinationViewController as AlbumHotViewController
            albumViewControl.dataSource = albumData
        }
    }
    
    
}

