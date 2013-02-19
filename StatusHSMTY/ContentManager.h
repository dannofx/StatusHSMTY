//
//  ContentManager.h
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HackerSpaceInfo.h"

@interface ContentManager : NSObject

-(void)launchContentUpdate;
-(void)launchContentUpdateWithURL:(NSString *)hackersURL;
-(void)eraseContent;
-(void)eraseContentFor:(HackerSpaceInfo *)hackerSpace;

-(void)saveImageToPath:(NSString *)pathImage;
-(void)deleteImageInPath:(NSString *)pathImage;


@end
