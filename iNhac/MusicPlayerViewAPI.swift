//
//  MusicPlayerViewAPI.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 4/21/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

extension MusicPlayerViewController{
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
                    
                    
                    var songObject:SongModel = SongModel(myID: tempsObject["ID"] as NSString, myTitle: tempsObject["Title"] as NSString, myArtist: self.songSource.Artist, myArtistID: self.songSource.ID, myComposer: "", myTotalListen: 0, myGenre: "", myArtistAvatar: self.songSource.ArtistAvatar, myLinkPlayEmbed: tempsObject["LinkPlayEmbed"] as NSString, myLink128: tempsObject["LinkPlay128"] as NSString, myLink320: tempsObject["LinkPlay320"] as NSString, myLink: tempsObject["Link"] as NSString)
                    
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

}