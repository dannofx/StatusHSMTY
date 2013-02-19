//
//  HackerSpaceInfo.h
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact, Event;

@interface HackerSpaceInfo : NSManagedObject

@property (nonatomic, retain) NSString * spaceName;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * address;
@property (nonatomic) float lat;
@property (nonatomic) float lon;
@property (nonatomic) NSTimeInterval lastchange;
@property (nonatomic, retain) NSString * iconURL;
@property (nonatomic, retain) NSString * iconPath;
@property (nonatomic, retain) NSString * openIconPath;
@property (nonatomic, retain) NSString * closedIconPath;
@property (nonatomic, retain) NSString * openIconURL;
@property (nonatomic, retain) NSString * closedIconURL;
@property (nonatomic) BOOL open;
@property (nonatomic, retain) NSSet *contacts;
@property (nonatomic, retain) NSSet *events;
@end

@interface HackerSpaceInfo (CoreDataGeneratedAccessors)

- (void)addContactsObject:(Contact *)value;
- (void)removeContactsObject:(Contact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
