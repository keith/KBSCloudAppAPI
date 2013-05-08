//
//  KBSCloudAppURL.h
//
//  Created by Keith Smiley
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KBSCloudAppURL : NSObject

@property (nonatomic, strong) NSURL *originalURL;
@property (nonatomic, strong) NSURL *shortURL;
@property (nonatomic, strong) NSString *name;

/*
  Methods for creating a KBSCloudAppURL object
 */
+ (instancetype)URLWithURL:(NSURL *)url;
+ (instancetype)URLWithURL:(NSURL *)url andName:(NSString *)name;
+ (instancetype)URLWithURL:(NSURL *)url andName:(NSString *)name andShortURL:(NSURL *)shortURL;
- (id)initWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url andName:(NSString *)name;
- (id)initWithURL:(NSURL *)url andName:(NSString *)name andShortURL:(NSURL *)shortURL;

/*
  Block: The Asyncrhonous return block **REQUIRED**
    NOTE: If this parameter is nil an exception will be raised
      shortURLs: An NSArray with a single KBSCloudAppURL object with the short and original URL
       response: An NSArray with a single NSDictionary with entire CloudApp API response
          error: An NSError that is returned if anything goes wrong

  See KBSCloudAppAPI shortenURLs
 */
- (void)shorten:(void(^)(NSArray *shortURLs, NSArray *response, NSError *error))block;

@end
