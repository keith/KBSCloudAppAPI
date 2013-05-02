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
      expect(exception).notTo.equal(nil);
    }
  });
  
  it(@"should raise an exception if no block is passed", ^{
    @try {
      [client shortenURL:url withName:@"foo" andBlock:(void*)0];
      expect(true).to.equal(false); // Should never reach this because of exception
    } @catch (NSException *exception) {
      expect(exception).notTo.equal(nil);
    }
  });
  
  it(@"should not raise an exception if no title is passed", ^{
    @try {
      [client shortenURL:url withName:nil andBlock:^(NSURL *shortURL, NSDictionary *response, NSError *error) {}];
      expect(true).to.equal(true);
    } @catch (NSException *exception) {
      expect(exception).to.equal(nil);
    }
  });
  
  it(@"should return an error if there is no username/password", ^{
    [client shortenURL:url withName:nil andBlock:^(NSURL *shortURL, NSDictionary *response, NSError *error) {
      expect(shortURL).to.equal(nil);
      expect(response).to.equal(nil);
      expect(error).notTo.equal(nil);

      NSDictionary *userInfo = [error userInfo];
      NSString *title = [userInfo valueForKey:NSLocalizedDescriptionKey];
      expect([title rangeOfString:@"CloudApp"].location == NSNotFound).to.equal(false); // It should contain 'CloudApp'

      NSString *description  = [userInfo valueForKey:NSLocalizedRecoverySuggestionErrorKey];
      expect([description rangeOfString:@"Missing"].location == NSNotFound).to.equal(false); // It should contain 'Missing'
    }];
  });
  
  describe(@"invalid credentials", ^{
    it(@"should return an error from the server", ^AsyncBlock {
      [client setUsername:@"foo" andPassword:@"bar"];
      [client shortenURL:url withName:nil andBlock:^(NSURL *shortURL, NSDictionary *response, NSError *error) {
        NSLog(@"Running Async Failure Examples");
        expect(shortURL).to.equal(nil);
        expect(response).to.equal(nil);
        expect(error).notTo.equal(nil);
        
        NSDictionary *userInfo = [error userInfo];
        NSString *title = [userInfo valueForKey:NSLocalizedDescriptionKey];
        expect([title rangeOfString:@"CloudApp"].location == NSNotFound).to.equal(false); // It should contain 'CloudApp'
        
        NSString *description  = [userInfo valueForKey:NSLocalizedRecoverySuggestionErrorKey];
        expect([description rangeOfString:@"Invalid"].location == NSNotFound).to.equal(false); // It should contain 'Invalid'

        done();
      }];
    });
  });
  
  describe(@"valid credentials", ^{
    it(@"should return a valid response", ^AsyncBlock {
      [client setUsername:@"" andPassword:@""];
      [client shortenURL:url withName:nil andBlock:^(NSURL *shortURL, NSDictionary *response, NSError *error) {
        NSLog(@"Running Async Valid Examples");
        expect(shortURL).notTo.equal(nil);
        expect(response).notTo.equal(nil);
        expect(error).will.equal(nil);
        
        NSString *redirectURL = [response valueForKey:@"redirect_url"];
        expect(redirectURL).will.equal([url absoluteString]);

        done();
      }];
    });
  });
});

SpecEnd
