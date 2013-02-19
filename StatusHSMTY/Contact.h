//
//  Contact.h
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HackerSpaceInfo;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * contactType;
@property (nonatomic, retain) NSString * contactData;
@property (nonatomic, retain) HackerSpaceInfo *hackerspace;

@end
