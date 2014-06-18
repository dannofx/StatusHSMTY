//
//  PushEnablerRequest.h
//  StatusHSMTY
//
//  Created by Danno on 3/5/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "ASIHTTPRequest.h"

@interface PushEnablerRequest : ASIHTTPRequest

+(PushEnablerRequest *)requestToModifyURL:(NSString *)url add:(BOOL)add;
+(PushEnablerRequest *)requestToAddToken: (NSString *)token WithURLs:(NSArray *)spaces;
+(PushEnablerRequest *)requestToDeleteToken;
+(BOOL)isPossibleEnablePush;

@end
