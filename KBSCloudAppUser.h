//
//  KBSCloudAppUser.h
//
//  Created by Keith Smiley
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KBSCloudAppUser : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *customDomain;

/*
  Methods for creating a KBSCloudAppUser
 */
+ (instancetype)userWithUsername:(NSString *)username andPassword:(NSString *)password;
- (id)initWithUsername:(NSString *)username andPassword:(NSString *)password;

/*
  Check to see if the user has a custom domain
    This is returned when isValid: is called, until then it will be false
 */
- (BOOL)hasCustomDomain;

/*
  Get the base of the shortURL
   If the user has a custom domain it will return that
   Otherwise it will return the normal cl.ly (currently)
 */
- (NSString *)shortURLBase;

/*
  Check to see if the user's credentials are valid
    If they are valid will be true and the error will be nil
    If they are not or there was an issue valid will be false and there will be an error
 */
- (void)isValid:(void(^)(BOOL valid, NSError *error))block;

/*
  This deletes all the store cookies that deal with CloudApp
   Use this whenever a user will change their information
   This is called when a new user is set to the API
 */
+ (void)clearCloudAppUsers;

/*
  Custom Errors
 */
+ (NSError *)invalidCredentialsError;
+ (NSError *)missingCredentialsError;

@end
