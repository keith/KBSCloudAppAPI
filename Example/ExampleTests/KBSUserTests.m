//
//  KBSUserTests.m
//  Example
//
//  Created by Keith Smiley on 5/8/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSCommon.h"

SpecBegin(KBSCloudAppUser)

NSString *token = [[[NSProcessInfo processInfo] environment] objectForKey:@"CLOUD_CREDENTIALS"];
NSArray *parts = [token componentsSeparatedByString:@":"];
__block NSString *username = [parts objectAtIndex:0];
__block NSString *password = [parts objectAtIndex:1];

beforeEach(^{
  [KBSCloudAppUser clearCloudAppUsers];
});

describe(@"user creation", ^{
  describe(@"instance method", ^{
    it(@"should return a user with the correct parameters", ^{
      KBSCloudAppUser *aUser = [[KBSCloudAppUser alloc] initWithUsername:@"foo" andPassword:@"bar"];
      expect(aUser.username).to.equal(@"foo");
      expect(aUser.username).notTo.equal(@"baz");
      expect(aUser.password).to.equal(@"bar");
      expect(aUser.password).notTo.equal(@"quux");
    });
  });

  describe(@"class method", ^{
    it(@"should return a user with the correct parameters", ^{
      KBSCloudAppUser *aUser = [KBSCloudAppUser userWithUsername:@"foo" andPassword:@"bar"];
      expect(aUser.username).to.equal(@"foo");
      expect(aUser.username).notTo.equal(@"baz");
      expect(aUser.password).to.equal(@"bar");
      expect(aUser.password).notTo.equal(@"quux");
    });
  });
});

describe(@"user validity", ^{
  describe(@"invalid user", ^{
    it(@"should return false and an error", ^AsyncBlock {
      KBSCloudAppUser *aUser = [KBSCloudAppUser userWithUsername:@"foo" andPassword:@"bar"];
      [aUser isValid:^(BOOL valid, NSError *error) {
        expect(valid).to.equal(false);
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

  describe(@"no user", ^{
    it(@"should return false and an error", ^AsyncBlock {
      KBSCloudAppUser *aUser = [[KBSCloudAppUser alloc] init];
      [aUser isValid:^(BOOL valid, NSError *error) {
        expect(valid).to.equal(false);
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

  describe(@"valid user", ^{
    it(@"should return true and no error", ^AsyncBlock {
      KBSCloudAppUser *aUser = [KBSCloudAppUser userWithUsername:username andPassword:password];
      [aUser isValid:^(BOOL valid, NSError *error) {
        expect(valid).to.equal(true);
        expect(error).to.equal(nil);

        done();
      }];
    }); 
  });
});

describe(@"hasCustomDomain/customDomain/shortURLBase", ^{
  it(@"should return false/nil/cl.ly for invalid users", ^AsyncBlock {
    KBSCloudAppUser *aUser = [KBSCloudAppUser userWithUsername:@"foo" andPassword:@"bar"];
    [aUser isValid:^(BOOL valid, NSError *error) {
      expect(valid).to.equal(false);
      expect(error).notTo.equal(nil);

      expect([aUser hasCustomDomain]).to.equal(false);
      expect([aUser customDomain]).to.equal(nil);
      expect([aUser shortURLBase]).to.equal(@"cl.ly");

      done();
    }];
  }); 

  it(@"should return false/nil/default for users without custom domains", ^AsyncBlock {
    KBSCloudAppUser *aUser = [KBSCloudAppUser userWithUsername:username andPassword:password];
    [aUser isValid:^(BOOL valid, NSError *error) {
      expect(valid).to.equal(true);
      expect(error).to.equal(nil);

      expect([aUser hasCustomDomain]).to.equal(false);
      expect([aUser customDomain]).to.equal(nil);
      expect([aUser shortURLBase]).to.equal(@"cl.ly");

      done();
    }];
  });

  it(@"should return true/url/url for users with custom domains", ^AsyncBlock {
    KBSCloudAppUser *aUser = [KBSCloudAppUser userWithUsername:@"foo" andPassword:@"bar"];
    [aUser isValid:^(BOOL valid, NSError *error) {
      expect(valid).to.equal(false);
      expect(error).notTo.equal(nil);

      [aUser setCustomDomain:@"foobar.com"]; // Set the URL for testing
      expect([aUser hasCustomDomain]).to.equal(true);
      expect([aUser customDomain]).to.equal(@"foobar.com");
      expect([aUser shortURLBase]).to.equal(@"foobar.com");

      done();
    }];
  });
});

describe(@"clear cookies", ^{
  it(@"should actually clear all the cookies", ^AsyncBlock {
    KBSCloudAppUser *aUser = [KBSCloudAppUser userWithUsername:username andPassword:password];
    [aUser isValid:^(BOOL valid, NSError *error) {
      expect(valid).to.equal(true);
      expect(error).to.equal(nil);

      NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:baseAPI]];
      expect(cookies.count).to.beGreaterThanOrEqualTo(1);
      [KBSCloudAppUser clearCloudAppUsers];
      cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:baseAPI]];
      expect(cookies.count).to.equal(0);

      done();
    }];
  });
});

SpecEnd
