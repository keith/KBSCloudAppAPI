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
});

SpecEnd
