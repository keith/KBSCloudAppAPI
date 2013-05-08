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
__block NSURL *baseURL = [NSURL URLWithString:@"http://github.com"];
__block KBSCloudAppURL *theURL = [KBSCloudAppURL URLWithURL:baseURL];
NSString *token = [[[NSProcessInfo processInfo] environment] objectForKey:@"CLOUD_CREDENTIALS"];
NSArray *parts = [token componentsSeparatedByString:@":"];
__block NSString *username = [parts objectAtIndex:0];
__block NSString *password = [parts objectAtIndex:1];

beforeEach(^{
  [KBSCloudAppUser clearCloudAppUsers];
});

describe(@"shortenURL", ^{
  
  it(@"should raise an exception if no URL is passed", ^{
    @try {
      [client shortenURLs:nil andBlock:^(NSArray *theURLs, NSArray *response, NSError *error) {}];
      expect(true).to.equal(false); // Should never reach this because of exception
    } @catch (NSException *exception) {
      expect(exception).notTo.equal(nil);
    }
  });
  
  it(@"should raise an exception if no block is passed", ^{
    @try {
      [client shortenURLs:@[theURL] andBlock:(void*)0];
      expect(true).to.equal(false); // Should never reach this because of exception
    } @catch (NSException *exception) {
      expect(exception).notTo.equal(nil);
    }
  });
  
  describe(@"invalid credentials", ^{
    it(@"should return an error from the server", ^AsyncBlock {
      KBSCloudAppUser *user = [[KBSCloudAppUser alloc] initWithUsername:@"foo" andPassword:@"bar"];
      [client setUser:user];
      [client shortenURLs:@[theURL] andBlock:^(NSArray *theURLs, NSArray *response, NSError *error) {
        NSLog(@"Running Async Failure Examples");
        expect(theURLs).to.equal(nil);
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
  
  describe(@"missing credentials", ^{
    it(@"should return an error from the server", ^AsyncBlock {
      [client setUser:nil];
      [client shortenURLs:@[theURL] andBlock:^(NSArray *theURLs, NSArray *response, NSError *error) {
        NSLog(@"Running Async Missing Examples");
        expect(theURLs).to.equal(nil);
        expect(response).to.equal(nil);
        expect(error).notTo.equal(nil);
        
        NSDictionary *userInfo = [error userInfo];
        NSString *title = [userInfo valueForKey:NSLocalizedDescriptionKey];
        expect([title rangeOfString:@"CloudApp"].location == NSNotFound).to.equal(false); // It should contain 'CloudApp'
        
        NSString *description  = [userInfo valueForKey:NSLocalizedRecoverySuggestionErrorKey];
        expect([description rangeOfString:@"Missing"].location == NSNotFound).to.equal(false); // It should contain 'Missing'
        
        done();
      }];
    });
  });
  
  describe(@"valid credentials", ^{
    it(@"should return a valid response", ^AsyncBlock {
      KBSCloudAppUser *user = [[KBSCloudAppUser alloc] initWithUsername:username andPassword:password];
      [client setUser:user];
      [client shortenURLs:@[theURL] andBlock:^(NSArray *theURLs, NSArray *response, NSError *error) {
        NSLog(@"Running Async Valid Examples");
        expect(theURLs).notTo.equal(nil);
        expect(theURLs.count).to.beGreaterThan(0);
        expect(response).notTo.equal(nil);
        expect(error).will.equal(nil);
        
        KBSCloudAppURL *aURL = [theURLs objectAtIndex:0];
        expect(aURL.originalURL).to.equal(baseURL);

        done();
      }];
    });
  });
});

describe(@"saving multiple URLs", ^{
  __block NSURL *url1 = [NSURL URLWithString:@"google.com"];
  __block NSURL *url2 = [NSURL URLWithString:@"gmail.com"];
  __block KBSCloudAppURL *theURL1 = [KBSCloudAppURL URLWithURL:url1];
  __block KBSCloudAppURL *theURL2 = [KBSCloudAppURL URLWithURL:url2];

  it(@"should return an array of both the shortened URLs with their original URLs", ^AsyncBlock {
    KBSCloudAppUser *user = [[KBSCloudAppUser alloc] initWithUsername:username andPassword:password];
    [client setUser:user];
    [client shortenURLs:@[theURL1, theURL2] andBlock:^(NSArray *theURLs, NSArray *response, NSError *error) {
      NSLog(@"Running Async multiple URL example");
      expect(theURLs.count).to.equal(2);
      expect(response.count).to.equal(2);
      expect(error).to.equal(nil);

      KBSCloudAppURL *responseURL1 = [theURLs objectAtIndex:0];
      expect(responseURL1.originalURL).to.equal(theURL1.originalURL);
      KBSCloudAppURL *responseURL2 = [theURLs objectAtIndex:1];
      expect(responseURL2.originalURL).to.equal(theURL2.originalURL);

      done();
    }];
  });
});

SpecEnd
