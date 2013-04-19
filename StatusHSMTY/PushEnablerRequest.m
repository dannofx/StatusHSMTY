//
//  PushEnablerRequest.m
//  StatusHSMTY
//
//  Created by Danno on 3/5/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "PushEnablerRequest.h"
#import "HackerSpaceInfo.h"
#import "Configuration.h"
#import "Reachability.h"
#import "GlobalConstants.h"

@implementation PushEnablerRequest


+(PushEnablerRequest *)requestToModifyURL:(NSString *)url add:(BOOL)add
{

    NSString * token=[Configuration pushToken];
    NSString * urlString= [NSString stringWithFormat:@"%@/%@",PUSH_ADDRESS,token];
    NSURL *urlSpace = [NSURL URLWithString:urlString];
    PushEnablerRequest * request=[self requestWithURL:urlSpace];
    [request setTimeOutSeconds:30.0];
    

    NSString * key=(add?@"add":@"del");
    NSArray * spaces=[NSArray arrayWithObjects:url, nil];
    
    NSDictionary *requestDictionary = [NSDictionary dictionaryWithObjectsAndKeys:spaces, key, nil];
    
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:requestDictionary options:kNilOptions error:nil];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request appendPostData:jsonData];
    [request setUseCookiePersistence:YES];
    [request setRequestMethod:@"POST"];
    
    
    return request;

}
+(PushEnablerRequest *)requestToAddToken: (NSString *)token WithURLs:(NSArray *)spaces
{
    NSString * urlString= [NSString stringWithFormat:@"%@/%@",PUSH_ADDRESS,token];
    NSURL *url = [NSURL URLWithString:urlString];
    PushEnablerRequest * request=[self requestWithURL:url];
    [request setTimeOutSeconds:30.0];
    
    NSMutableArray * spacesAddresses=[[NSMutableArray alloc] init];
    
    for(HackerSpaceInfo * space in spaces)
    {
        [spacesAddresses addObject:space.url_status];
    }
    

    NSDictionary *finalDictionary = [NSDictionary dictionaryWithObjectsAndKeys:spaces, @"spaceapi", nil];
    
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:finalDictionary options:kNilOptions error:nil];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request appendPostData:jsonData];
    [request setUseCookiePersistence:YES];
    [request setRequestMethod:@"PUT"];

    
    return request;
}
+(PushEnablerRequest *)requestToDeleteToken
{
    NSString * token=[Configuration pushToken];
    NSString * urlString= [NSString stringWithFormat:@"%@/%@",PUSH_ADDRESS,token];
    NSURL *url = [NSURL URLWithString:urlString];
    PushEnablerRequest * request=[self requestWithURL:url];
    [request setTimeOutSeconds:31.0];
    [request setRequestMethod:@"DELETE"];
    return request;
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
