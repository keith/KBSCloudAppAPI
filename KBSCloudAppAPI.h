//
//  KBSCloudAppAPI.h
//
//  Created by Keith Smiley
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KBSCloudAppUser;

@interface KBSCloudAppAPI : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) KBSCloudAppUser *user;

+ (KBSCloudAppAPI *)sharedClient;

- (void)shortenURL:(NSURL *)url withName:(NSString *)name andBlock:(void(^)(NSURL *shortURL, NSDictionary *response, NSError *error))block;

- (void)hasValidAccount:(void(^)(BOOL valid, NSError *error))block;
- (void)setUsername:(NSString *)name andPassword:(NSString *)pass;
- (BOOL)hasUsernameAndPassword;
- (void)clearUsernameAndPassword;

@end
