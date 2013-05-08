# KBSCloudAppAPI

This is a simple Objective-C API client for [CloudApp](http://getcloudapp.com/). Currently this only supports shortening (bookmarking) URLs. If you'd like more features I suggest you check out the [official](https://github.com/cloudapp/objective-c) Objective-C API client. Although in the future I _may_ also add support for file uploads in the future.

[![Build Status](https://travis-ci.org/Keithbsmiley/KBSCloudAppAPI.png?branch=master)](https://travis-ci.org/Keithbsmiley/KBSCloudAppAPI)

# Usage

There are 3 classes that work together to make up this API client:

- KBSCloudAppAPI
- KBSCloudAppUser
- KBSCloudAppURL

The general outline of how these work together is like this:

1. Create a `KBSCloudAppUser` object with a user's credentials.
2. Assign that user to the shared `KBSCloudAppAPI` instance.
3. Create one or more `KBSCloudAppURL` objects with the URLs you want to shorten
4. Call `KBSCloudAppAPI`'s `shortenURLs` method passing an `NSArray` with 1 or more `KBSCloudAppURL`s
5. Receive the asynchronous response, in the form of a block, with an `NSArray` of `KBSCloudAppURL` objects that have both the shortened and original URLs associated with them

Example User validation:

```
KBSCloudAppUser *user = [[KBSCloudAppUser alloc] initWithUsername:username andPassword:password];
[user isValid:^(BOOL valid, NSError *error) {
  if (valid) {
    // Do stuff  
  } else {
    // Handle error  
  }
}];
```

Example URL shorten:

```
KBSCloudAppAPI *api = [KBSCloudAppAPI sharedClient];
[api setUser:user];
KBSCloudAppURL *url = [KBSCloudAppURL URLWithURL:[NSURL URLWithString:@"http://github.com/"]];
[api shortenURLs:@[url] andBlock:^(NSArray *theURLs, NSArray *response, NSError *error) {
  if (error) {
    // Handle error
  } else {
    KBSCloudAppURL *theURL = [theURLs objectAtIndex:0];
    // The shortened url is theURL.shortURL
  }
}];
```

Check out the header files for tons of documentation and the example project and tests for example usage.

# Installation

You shouldn't need anything special in order to make this work with your project. If you'd like to run the tests make sure to execute `./setup.sh` to clone the frameworks. You'll also need to set an environment variable like:

```
export CLOUD_CREDENTIALS="username:password"
```

In order to run the tests that actually shorten (and therefore add to your CloudApp items) URLs.
