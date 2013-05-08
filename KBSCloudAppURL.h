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

+ (instancetype)URLWithURL:(NSURL *)url;
+ (instancetype)URLWithURL:(NSURL *)url andName:(NSString *)name;
+ (instancetype)URLWithURL:(NSURL *)url andName:(NSString *)name andShortURL:(NSURL *)shortURL;
- (id)initWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url andName:(NSString *)name;
- (id)initWithURL:(NSURL *)url andName:(NSString *)name andShortURL:(NSURL *)shortURL;

- (void)shorten:(void(^)(NSURL *shortURL, NSDictionary *response, NSError *error))block;

@end
