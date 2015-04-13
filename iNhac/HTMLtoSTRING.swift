//
//  HTMLtoSTRING.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 4/13/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//


extension String {
    var html2String:String {
        return NSAttributedString(data: dataUsingEncoding(NSUnicodeStringEncoding)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil, error: nil)!.string
    }
}
