//
//  NSString+MD5.m
//  iNhac
//
//  Created by Zoom NGUYEN on 4/2/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

#import "NSString+MD5.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

#include <sys/types.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

@implementation NSString (MD5)

-(NSString*)HMAC_MD5_WithSecretString:(NSString*)secret{
    
    CCHmacContext    ctx;
    
    const char       *key = [secret UTF8String];
    
    const char       *str = [self UTF8String];
    
    unsigned char    mac[CC_MD5_DIGEST_LENGTH];
    
    char             hexmac[2 * CC_MD5_DIGEST_LENGTH + 1];
    
    char             *p;
    
    CCHmacInit( &ctx, kCCHmacAlgMD5, key, strlen( key ));
    
    CCHmacUpdate( &ctx, str, strlen(str) );
    
    CCHmacFinal( &ctx, mac );
    
    p = hexmac;
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ ) {
        
        snprintf( p, 3, "%02x", mac[ i ] );
        
        p += 2;
        
    }
    
    return [NSString stringWithUTF8String:hexmac];
    
}

- (NSString *) URLEncodedString_ch {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}




@end
