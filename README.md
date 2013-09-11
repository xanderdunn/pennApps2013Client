# Swap

Update your iOS app in real-time.

## Usage
1) Import PAAdminClient.h into your app.

2) Get a token from the web front end at http://pennappsbackend.herokuapp.com

3) Initialize the admin client somewhere in your app using that token, probably in AppDelegate.m didFinishlaunching: `[[PAAdminClient sharedAdminClient] setToken:@"_htlu5-G149w7xONSbdIKg"];`

4) If you want push notification support, add this to your AppDelegate.m:
```objc
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSString *type = [userInfo objectForKey:@"type"];
    if ([type isEqualToString:@"pennapps"]) {
        [[PAAdminClient sharedAdminClient] refreshData];
    }
}
```

5) Be Amazing.

## Libraries used

- [Cycript](http://www.cycript.org) by Jay Freeman

## License

Swap is available under the GPLv3 license. See the LICENSE file for more info.

## Contact

This is the winning hack for PennApps Fall 2013 by
Conrad Kramer, High School Senior
Nathan Eidelson, Stanford
Andrew Aude, Stanford
Alex Dunn, University of Chicago

Contact us at swapdevs@gmail.com
