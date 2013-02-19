//
//  Event.h
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * attendant;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) NSTimeInterval initDate;
@property (nonatomic, retain) NSManagedObject *hackerSpace;

@end
