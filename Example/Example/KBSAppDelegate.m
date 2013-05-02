//
//  KBSAppDelegate.m
//  Example
//
//  Created by Keith Smiley on 4/24/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KBSAppDelegate.h"
#import "KBSCloudAppAPI.h"
#include <stdlib.h>

@implementation KBSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  KBSCloudAppAPI *api = [KBSCloudAppAPI sharedClient];
  [api setUsername:@"" andPassword:@""];

  NSURL *url = [NSURL URLWithString:@"http://github.com/"];
  [api shortenURL:url withName:nil andBlock:^(NSURL *responseURL, NSDictionary *response, NSError *error) {
    if (error) {
      NSLog(@"%@", error);
      [[NSAlert alertWithError:error] runModal];
    } else {
      NSLog(@"%@", responseURL);
      NSLog(@"%@", response);
    }
  }];
}

@end
