//
//  AppDelegate.m
//  StatusHSMTY
//
//  Created by Danno on 2/18/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "AppDelegate.h"
#import "Configuration.h"
#import "ContentManager.h"

@interface AppDelegate()

-(void)launchSpaceUpdateNotificationWithURL:(NSString *)url;

@end

@implementation AppDelegate

- (void)dealloc
{

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber =0;
	if (launchOptions != nil)
	{
		NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
            [Configuration setCurrentSpaceAPIURL:@"miurl"];
            [self launchSpaceUpdateNotificationWithURL:@"miurl"];
			NSLog(@"Launched from push notification: %@", dictionary);
			//[self addMessageFromRemoteNotification:dictionary updateUI:NO];
		}
	}
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    managedObjectModel_ = [NSManagedObjectModel mergedModelFromBundles:nil];
    return managedObjectModel_;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSString* dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *storeURL = [NSURL fileURLWithPath:[dir stringByAppendingPathComponent:@"MP.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator_;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


#pragma mark -
#pragma mark Push notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSString* oldToken = [Configuration pushToken];
	NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];

	if (![newToken isEqualToString:oldToken])
	{
		[[ContentManager contentManager] launchUpdateForPushToken:newToken];
	}
}



- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	// If we get here, the app could not obtain a device token. In that case,
	// the user can still send messages to the server but the app will not
	// receive any push notifications when other users send messages to the
	// same chat room.
    NSString * oldToken=[Configuration pushToken];
    if(oldToken!=nil)
    {
        [[ContentManager contentManager] launchTokenRemoval];
    }
    

}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    NSString* urlValue = [userInfo valueForKey:@"url"];
    [Configuration setCurrentSpaceAPIURL:urlValue];
    [self launchSpaceUpdateNotificationWithURL:urlValue];
}


-(void)launchSpaceUpdateNotificationWithURL:(NSString *)url
{
    if(url!=nil)
    {
        [[ContentManager contentManager] launchContentUpdateWithURL:url];
    }

}


@end
