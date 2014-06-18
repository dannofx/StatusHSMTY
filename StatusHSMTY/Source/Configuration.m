//
//  Configuration.m
//  StatusHSMTY
//
//  Created by Danno on 2/22/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "Configuration.h"
#import "GlobalConstants.h"
#import "STKeychain.h"

@implementation Configuration

+(void)setCurrentSpaceName:(NSString *)spaceName
{
    [[NSUserDefaults standardUserDefaults] setObject:spaceName forKey:KEY_SPACENAME_SETTINGS];
}
+(NSString *)currentSpaceName{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KEY_SPACENAME_SETTINGS];
}

+(void)setCurrentSpaceAPIURL:(NSString *)spaceURL
{
    [[NSUserDefaults standardUserDefaults] setObject:spaceURL forKey:KEY_SPACEURL_SETTINGS];
}
+(NSString *)currentSpaceAPIURL{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KEY_SPACEURL_SETTINGS];
}


+(void)setPushToken:(NSString *)token
{
    if(token)
        [STKeychain storeUsername:PUSH_TOKEN_KEY andPassword:token forServiceName:PUSH_TOKEN_KEYCHAIN updateExisting:YES error:nil];
    else
        [STKeychain deleteItemForUsername:PUSH_TOKEN_KEY andServiceName:PUSH_TOKEN_KEYCHAIN error:nil];
    
}
+(NSString *)pushToken
{
    return [STKeychain getPasswordForUsername:PUSH_TOKEN_KEY andServiceName:PUSH_TOKEN_KEYCHAIN error:nil];
}
+(void)setUUIDForApp:(NSString *)token
{
    if(token)
        [STKeychain storeUsername:UUID_KEY andPassword:token forServiceName:UUID_KEYCHAIN updateExisting:YES error:nil];
    else
        [STKeychain deleteItemForUsername:UUID_KEY andServiceName:UUID_KEYCHAIN error:nil];
    
}
+(NSString *)UUIDForApp
{
    NSString * currentUUID= [STKeychain getPasswordForUsername:UUID_KEY andServiceName:UUID_KEYCHAIN error:nil];
    
    if(currentUUID==nil)
    {
        CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
        currentUUID = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
        CFRelease(uuidObject);
        [self setUUIDForApp:currentUUID];
    }
    
    return currentUUID;
}

@end
