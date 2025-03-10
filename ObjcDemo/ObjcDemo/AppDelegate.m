//
//  AppDelegate.m
//  ObjcDemo
//
//  Created by duyenlv on 26/2/25.
//

#import "AppDelegate.h"
#import "PolarGX/PolarGX.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    PolarApp.isDevelopmentEnabled = true;
    PolarApp.isLoggingEnabled = true;
    [PolarApp initializeWithAppId:@"ad71f83f-4bc3-447a-94c8-d78c3ec8cce2" apiKey:@"XRMKcQBoHk6U9IZgsgjL56nDxCLzNYYak9pxweI3" onLinkClickHandler:^(NSURL * _Nonnull url, NSDictionary<NSString *,id> * _Nullable attributes, NSError * _Nullable error) {
        NSLog(@"[DEMO] detect clicked: %@, data: %@, error: %@\n", url, attributes, error);

    }];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return [PolarApp.shared continueUserActivity:userActivity];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [PolarApp.shared openUrl:url];
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
