//
//  Event.h
//  StatusHSMTY
//
//  Created by Danno on 2/26/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HackerSpaceInfo;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * attendant;
@property (nonatomic) NSTimeInterval time;
@property (nonatomic) NSTimeInterval start;
@property (nonatomic) NSTimeInterval end;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * extra;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic) BOOL checkEvent;
@property (nonatomic, retain) HackerSpaceInfo *hackerSpace;
@property (nonatomic,readonly) NSDate * startDate;
@property (nonatomic,readonly) NSDate * endDate;
@property (nonatomic,readonly) NSDate * timeDate;

@property (nonatomic) UIImage * image;

//-(NSString *) humanTime;

@end
