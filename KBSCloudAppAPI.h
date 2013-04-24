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

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

- (KBSCloudAppAPI *)sharedClient;

@end
