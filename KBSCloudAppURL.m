//
//  KBSCloudAppURL.m
//
//  Created by Keith Smiley
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSCloudApp.h"
#import "KBSCloudAppURL.h"

@implementation KBSCloudAppURL

+ (instancetype)URLWithURL:(NSURL *)url {
  return [[KBSCloudAppURL alloc] initWithURL:url andName:nil andShortURL:nil];
}

+ (instancetype)URLWithURL:(NSURL *)url andName:(NSString *)name {
  return [[KBSCloudAppURL alloc] initWithURL:url andName:name andShortURL:nil];
}

+ (instancetype)URLWithURL:(NSURL *)url andName:(NSString *)name andShortURL:(NSURL *)shortURL {
  return [[KBSCloudAppURL alloc] initWithURL:url andName:name andShortURL:shortURL];
}

- (id)initWithURL:(NSURL *)url {
  return [self initWithURL:url andName:nil];
}

- (id)initWithURL:(NSURL *)url andName:(NSString *)name {
  return [self initWithURL:url andName:name andShortURL:nil];
}

- (id)initWithURL:(NSURL *)url andName:(NSString *)name andShortURL:(NSURL *)shortURL {

  self = [super init];
  if (!self) {
    return nil;
  }
  
  self.originalURL = [url copy];
  if (name) {
    self.name = [name copy];
  }

  if (shortURL) {
    self.shortURL = [shortURL copy];
  }
  
  return self;
}

- (void)shorten:(void(^)(NSArray *shortURLs, NSArray *response, NSError *error))block {
  [[KBSCloudAppAPI sharedClient] shortenURLs:@[self] andBlock:block];
}

@end
