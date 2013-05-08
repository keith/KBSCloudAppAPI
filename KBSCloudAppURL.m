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
  return [[KBSCloudAppURL alloc] initWithURL:url andName:nil];
}

+ (instancetype)URLWithURL:(NSURL *)url andName:(NSString *)name {
  return [[KBSCloudAppURL alloc] initWithURL:url andName:name];
}

- (id)initWithURL:(NSURL *)url {
  return [self initWithURL:url andName:nil];
}

- (id)initWithURL:(NSURL *)url andName:(NSString *)name {
  self = [super init];
  if (!self) {
    return nil;
  }
  
  self.originalURL = [url copy];
  if (name) {
    self.name = [name copy];
  }
  
  return self;
}

- (void)shorten:(void(^)(NSURL *shortURL, NSDictionary *response, NSError *error))block {
  [[KBSCloudAppAPI sharedClient] shortenURL:self.originalURL withName:self.name andBlock:block];
}

@end
