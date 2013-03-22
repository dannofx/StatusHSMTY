//
//  PushEnablerRequest.m
//  StatusHSMTY
//
//  Created by Danno on 3/5/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "PushEnablerRequest.h"
#import "Configuration.h"
#import "Reachability.h"

@implementation PushEnablerRequest

+(PushEnablerRequest *)requestToDeleteURL:(NSString *)url
{
    return nil;
}
+(PushEnablerRequest *)requestToAddURL:(NSString *)url
{
    return nil;
}
+(PushEnablerRequest *)requestToDeleteToken
{
    return nil;
}
+(BOOL)isPossibleEnablePush
{
    
    if([Configuration pushToken]==nil)
    {
        return NO;
    }
    return [[Reachability reachabilityForInternetConnection] isReachable];
}

@end
