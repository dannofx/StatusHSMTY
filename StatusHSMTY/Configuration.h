//
//  Configuration.h
//  StatusHSMTY
//
//  Created by Danno on 2/22/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Configuration : NSObject

+(void)setCurrentSpaceName:(NSString *)spaceName;
+(NSString *)currentSpaceName;
+(void)setCurrentSpaceAPIURL:(NSString *)spaceURL;
+(NSString *)currentSpaceAPIURL;
+(void)setPushToken:(NSString *)token;
+(NSString *)pushToken;
+(void)setUUIDForApp:(NSString *)token;
+(NSString *)UUIDForApp;
@end
