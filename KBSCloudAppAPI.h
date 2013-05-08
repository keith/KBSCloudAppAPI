//
//  KBSCloudAppAPI.h
//
//  Created by Keith Smiley
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KBSCloudAppUser;

@interface KBSCloudAppAPI : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

/*
   This is the KBSCloudAppUser object you should set with
    a custom user

   This is used when CloudApp asks for authentication
 */
@property (nonatomic, strong) KBSCloudAppUser *user;

/*
   This shared instance of KBSCloudAppAPI is used for shortening URLs
    You probably shouldn't create your own instance of this
    Although I don't see any reason it wouldn't work
 */
+ (KBSCloudAppAPI *)sharedClient;

/*
   This method shortens the passed URL via CloudApp and returns the short URL
    In the form of a block, it also returns the rest of the response if you need it
    Or an error if something went wrong

TODO: FIX THIS
   @params
     URL: The NSURL object to be shortened **REQUIRED**
       NOTE: If this parameter is not passed or nil an exception will be raised

     Block: This is the asyncronous return block **REQUIRED**
      NOTE: If this parameter is not passed or nil an exception will be raised
       theURL: An KBSCloudAppURL object with the short version along with the original URL
       response: The entire response from the CloudApp API shown here:
         https://github.com/cloudapp/api/blob/master/bookmark-link.md
       error: An error returned if there is an issue with the user or request
 */
- (void)shortenURLs:(NSArray *)urls andBlock:(void(^)(NSArray *theURLs, NSArray *response, NSError *error))block;

@end
