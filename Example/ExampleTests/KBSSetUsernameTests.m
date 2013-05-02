//
//  KBSSetUsernameTests.m
//  Example
//
//  Created by Keith Smiley on 5/1/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSCommon.h"

SpecBegin(UsernameAndPassword)

__block KBSCloudAppAPI *client = [KBSCloudAppAPI sharedClient];
__block NSString *username = @"foo";
__block NSString *password = @"bar";

describe(@"setUsernameAndPassword", ^{  
  beforeEach(^{
    [client clearUsernameAndPassword];
  });

  it(@"should save the username and password", ^{
    expect([client hasUsernameAndPassword]).to.equal(false);
    [client setUsername:username andPassword:password];
    expect([client hasUsernameAndPassword]).to.equal(true);
  });
});

describe(@"clearUsernameAndPassword", ^{
  beforeEach(^{
    [client setUsername:username andPassword:password];
  });
  
  it(@"should remove the username & password", ^{
    expect([client hasUsernameAndPassword]).to.equal(true);
    [client clearUsernameAndPassword];
    expect([client hasUsernameAndPassword]).to.equal(false);
  });
  
  it(@"should remove all associated cookies", ^{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://my.cl.ly"]];
    expect(cookies.count).to.equal(0);
  });
});

SpecEnd