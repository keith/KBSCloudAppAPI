//
//  KBSShortenURLTests.m
//  Example
//
//  Created by Keith Smiley on 5/2/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSCommon.h"

SpecBegin(ShortenURL)

__block KBSCloudAppAPI *client = [KBSCloudAppAPI sharedClient];
__block NSURL *url = [NSURL URLWithString:@"http://github.com"];

describe(@"shortenURL", ^{
  it(@"should raise an exception if no URL is passed", ^{
    @try {
      [client shortenURL:nil withName:@"foo" andBlock:^(NSURL *shortURL, NSDictionary *response, NSError *error) {}];
      expect(true).to.equal(false); // Should never reach this because of exception
    } @catch (NSException *exception) {
      expect(exception).toNot.equal(nil);
    }
  });
  
  it(@"should raise an exception if no block is passed", ^{
    @try {
      [client shortenURL:url withName:@"foo" andBlock:(void*)0];
      expect(true).to.equal(false); // Should never reach this because of exception
    } @catch (NSException *exception) {
      expect(exception).toNot.equal(nil);
    }
  });
});

SpecEnd
