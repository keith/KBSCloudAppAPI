//
//  KBSCloudAppUser.h
//
//  Created by Keith Smiley
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KBSCloudAppUser : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong, readonly) NSString *customDomain;

- (id)initWithUsername:(NSString *)username andPassword:(NSString *)password;
- (void)setUserPassword:(NSString *)password;

- (BOOL)hasCustomDomain;
- (void)isValid:(void(^)(BOOL valid, NSError *error))block;

@end
