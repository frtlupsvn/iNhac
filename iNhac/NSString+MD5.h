//
//  NSString+MD5.h
//  iNhac
//
//  Created by Zoom NGUYEN on 4/2/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Base64.h"

@interface NSString (MD5)
-(NSString*)HMAC_MD5_WithSecretString:(NSString*)secret;
-(NSString *) URLEncodedString_ch;
@end
