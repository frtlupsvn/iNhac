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
        
        let jsonarray:NSMutableDictionary = NSMutableDictionary(object: "song", forKey: "t")
        jsonarray.setValue(songSource.ID, forKey: "id")
        
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
        
        print(url)
        
        manager.GET( url,
            parameters: nil,
            success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                //Success
                print("Lyrics Successful")
                
                //                ********************************
                //                ** parse data to Object ********
                //                ********************************
                let results:NSDictionary = responseObject as! NSDictionary
                let lyrics : NSString? = results["Lyrics"] as? NSString
                
                
                if(lyrics != nil){
                    self.songLyrics.text = results["Lyrics"] as! String
                } else {
                    self.songLyrics.text = "Lời bài hát đang được cập nhật... \nCảm ơn"
                }
                
                //                ********************************
                //                ** END *************************
                //                ********************************
            },
            failure: {
                (operation: AFHTTPRequestOperation!,error: NSError!) in print("Error:" + error.localizedDescription)
                self.songLyrics.text = "Lời bài hát đang được cập nhật... \nCảm ơn"
            }
        )
        //**************************************
        self.songLyrics.setNeedsDisplay()
        
    }
    
    func loadSongRelate(){
        //jsondata
        
        let jsonarray:NSMutableDictionary = NSMutableDictionary(object: "song", forKey: "t")
        jsonarray.setValue(songSource.ArtistID, forKey: "id")
        
        let jsondata:NSString = (jsonarray.JSONString() as NSString)
            .base64EncodedStringWithWrapWidth(0)
            .stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            .URLEncodedString_ch()
        
        let signature:NSString = (jsondata as NSString).HMAC_MD5_WithSecretString(privateKey as String)
        
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html") as Set<NSObject>
        
        //**************************************
        // CALL API
        
        let url =  "\(ARTIST_RELATE_API)?publicKey=\(publicKey)&signature=\(signature)&jsondata=\(jsondata)"
       
        print(url)
        
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
                    
                    
                    let tempsObject:NSDictionary = responseArray[index] as! NSDictionary
                    
                    
                    let songObject:SongModel = SongModel(myID: tempsObject["ID"] as! NSString, myTitle: tempsObject["Title"] as! NSString, myArtist: self.songSource.Artist, myArtistID: self.songSource.ID, myComposer: "", myTotalListen: 0, myGenre: "", myArtistAvatar: self.songSource.ArtistAvatar, myLinkPlayEmbed: tempsObject["LinkPlayEmbed"] as! NSString, myLink128: tempsObject["LinkPlay128"] as! NSString, myLink320: tempsObject["LinkPlay320"] as! NSString, myLink: tempsObject["Link"] as! NSString)
                    
                    self.dataSource.addObject(songObject)
                    
                    
                    
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

}