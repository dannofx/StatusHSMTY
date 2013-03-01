//
//  NSDate+HSMTYFormats.m
//  StatusHSMTY
//
//  Created by Danno on 2/21/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "NSDate+HSMTYFormats.h"

@implementation NSDate (HSMTYFormats)


-(NSString *)stringDateWithCompleteFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yy HH:mm:ss"];
    //Setea zona horaria actual
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    NSString * localeIdentifier=[[NSLocale currentLocale] localeIdentifier];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier]];
    return [formatter stringFromDate:self];
}

-(NSString *)stringDateWithShortFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yy"];
    //Setea zona horaria actual
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    NSString * localeIdentifier=[[NSLocale currentLocale] localeIdentifier];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier]];
    return [formatter stringFromDate:self];
}
@end
