//
//  PushEnablerRequest.h
//  StatusHSMTY
//
//  Created by Danno on 3/5/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "ASIHTTPRequest.h"

@interface PushEnablerRequest : ASIHTTPRequest

+(PushEnablerRequest *)requestToDeleteURL:(NSString *)url;
+(PushEnablerRequest *)requestToAddURL:(NSString *)url;
+(PushEnablerRequest *)requestToDeleteToken;
+(BOOL)isPossibleEnablePush;
@end
