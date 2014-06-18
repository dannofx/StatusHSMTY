//
//  Event.h
//  StatusHSMTY
//
//  Created by Danno on 21/04/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#ifndef EVENT_TYPES
#define EVENT_TYPES
#define EVENT_TYPE_CHECKIN 1
#define EVENT_TYPE_CHECKOUT 2
#define EVENT_TYPE_CUSTOM 0
#endif

@class HackerSpaceInfo;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * attendant;
@property (nonatomic) NSTimeInterval end;
@property (nonatomic, retain) NSString * extra;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) NSTimeInterval start;
@property (nonatomic) NSTimeInterval time;
@property (nonatomic) int16_t type;
@property (nonatomic) BOOL standarEvent;
@property (nonatomic, retain) HackerSpaceInfo *hackerSpace;

@property (nonatomic,readonly) NSDate * startDate;
@property (nonatomic,readonly) NSDate * endDate;
@property (nonatomic,readonly) NSDate * timeDate;

@property (nonatomic) UIImage * image;


@end
