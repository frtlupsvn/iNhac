//
//  VideoModel.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 4/10/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

import UIKit

class VideoModel: NSObject {

    var ID : NSString
    var Title:NSString
    var Artist:NSString
    var ArtistID:NSString
    var TotalView:Int
    var Genre:NSString
    var PictureURL:NSString
    var LinkDownload:NSString
    var LinkPlayEmbed:NSString
    var Link:NSString
    
    
    init(myID:NSString,
        myTitle:NSString,
        myArtist:NSString,
        myArtistID:NSString,
        myTotalView:Int,
        myGenre:NSString,
        myPictureURL:NSString,
        myLinkDownload:NSString,
        myLinkPlayEmbed:NSString,
        myLink:NSString) {
            
            self.ID = myID
            self.Title = myTitle
            self.Artist = myArtist
            self.ArtistID = myArtistID
            self.TotalView = myTotalView
            self.Genre = myGenre
            self.PictureURL = myPictureURL
            self.LinkDownload = myLinkDownload
            self.LinkPlayEmbed = myLinkPlayEmbed
            self.Link = myLink
            
    }
    
    override init(){
        self.ID = ""
        self.Title = ""
        self.Artist = ""
        self.ArtistID = ""
        self.TotalView = 0
        self.Genre = ""
        self.PictureURL = ""
        self.LinkDownload = ""
        self.LinkPlayEmbed = ""
        self.Link = ""
    }
}
