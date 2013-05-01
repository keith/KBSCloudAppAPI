//
//  KBSSetUsernameTests.m
//  Example
//
//  Created by Keith Smiley on 5/1/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSCommon.h"

SpecBegin(UsernameAndPassword)

describe(@"setUsernameAndPassword", ^{
  __block KBSCloudAppAPI *client = [KBSCloudAppAPI sharedClient];
  __block NSString *username = @"foo";
  __block NSString *password = @"bar";
  
  beforeEach(^{
    [client clearUsernameAndPassword];
  });

  it(@"should save the username and password", ^{
    expect([client username]).to.equal(nil);
    expect([client password]).to.equal(nil);
    [client setUsername:username andPassword:password];
    expect([client username]).to.equal(username);
    expect([client password]).to.equal(password);
  });
  
  it(@"should have an authorization header", ^{
    expect([client defaultValueForHeader:@"Authorization"]).to.equal(nil);
    [client setUsername:username andPassword:password];
    expect([client defaultValueForHeader:@"Authorization"]).toNot.equal(nil);
  });
});

SpecEnd