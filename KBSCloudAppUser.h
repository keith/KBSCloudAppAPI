//
//  KBSCloudAppUser.h
//
//  Created by Keith Smiley
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KBSCloudAppUser : NSObject

@property (nonatomic, strong) NSString *username;

- (id)initWithUsername:(NSString *)username andPassword:(NSString *)password;
- (void)setUserPassword:(NSString *)password;
- (void)isValid:(void(^)(BOOL *valid))block;

@end
