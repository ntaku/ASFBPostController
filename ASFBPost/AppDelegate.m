//
//  Copyright (c) 2012 AppStair LLC. All rights reserved.
//  http://appstair.com
//

#import "AppDelegate.h"
#import "MainController.h"

@interface AppDelegate()

@property (nonatomic, retain) MainController *mainCtrl;

@end


@implementation AppDelegate

@synthesize window      = _window;
@synthesize facebook    = _facebook;
@synthesize mainCtrl    = _mainCtrl;

- (void)dealloc{
    _facebook = nil;
    [_mainCtrl release], _mainCtrl = nil;
    [_window release], _window = nil;
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    
    MainController *c = [[MainController alloc] init];
    self.mainCtrl = c;
    [c release];
    
    [self.window addSubview:self.mainCtrl.view];    
    [self.window makeKeyAndVisible];
    return YES;
}

// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.facebook handleOpenURL:url];
}


- (void)applicationWillResignActive:(UIApplication *)application{}

- (void)applicationDidEnterBackground:(UIApplication *)application{}

- (void)applicationWillEnterForeground:(UIApplication *)application{}

- (void)applicationDidBecomeActive:(UIApplication *)application{}

- (void)applicationWillTerminate:(UIApplication *)application{}

@end
