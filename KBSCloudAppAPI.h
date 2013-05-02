//
//  KBSCloudAppAPI.h
//
//  Created by Keith Smiley on 4/24/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

NS_ENUM(NSInteger, KBSCloudAppAPIErrorCode) {
  KBSCloudAppNoUserOrPass,
  KBSCloudAppAPIInvalidUser
};

extern NSString * const KBSCloudAppAPIErrorDomain;

@interface KBSCloudAppAPI : AFHTTPClient

+ (KBSCloudAppAPI *)sharedClient;

- (void)shortenURL:(NSURL *)url withName:(NSString *)name andBlock:(void(^)(NSURL *shortURL, NSDictionary *response, NSError *error))block;

- (void)setUsername:(NSString *)name andPassword:(NSString *)pass;
- (BOOL)hasUsernameAndPassword;
- (void)clearUsernameAndPassword;

@end
