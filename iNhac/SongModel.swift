//
//  SongModel.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 4/15/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//


class SongModel: NSObject {
    
    var ID : NSString
    var Title:NSString
    var Artist:NSString
    var ArtistID:NSString
    var Composer:NSString
    var TotalListen:Int
    var Genre:NSString
    var ArtistAvatar:NSString
    
    var LinkPlayEmbed:NSString
    var Link128:NSString
    var Link320:NSString
    var Link:NSString
    
    init(myID:NSString,
        myTitle:NSString,
        myArtist:NSString,
        myArtistID:NSString,
        myComposer:NSString,
        myTotalListen:Int,
        myGenre:NSString,
        myArtistAvatar:NSString,
        myLinkPlayEmbed:NSString,
        myLink128:NSString,
        myLink320:NSString,
        myLink:NSString) {
            
            self.ID = myID
            self.Title = myTitle
            self.Artist = myArtist
            self.ArtistID = myArtistID
            self.Composer = myComposer
            self.TotalListen = myTotalListen
            self.Genre = myGenre
            self.ArtistAvatar = myArtistAvatar
            self.LinkPlayEmbed = myLinkPlayEmbed
            self.Link128 = myLink128
            self.Link320 = myLink320
            self.Link = myLink
            
    }


    override init(){
        self.ID = ""
        self.Title = ""
        self.Artist = ""
        self.ArtistID = ""
        self.Composer = ""
        self.TotalListen = 0
        self.Genre = ""
        self.ArtistAvatar = ""
        self.LinkPlayEmbed = ""
        self.Link128 = ""
        self.Link320 = ""
        self.Link = ""

    }
}
