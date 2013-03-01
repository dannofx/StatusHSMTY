//
//  ContentManager.h
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HackerSpaceInfo.h"
#import "DownloadRequest.h"

@protocol HackerSpaceSelectionDelegate <NSObject>

-(void)requestForhackerSpaceSelection;

@end
@interface ContentManager : NSObject

@property (nonatomic, readonly) BOOL updating;
@property (nonatomic, weak)  id<HackerSpaceSelectionDelegate> selectionDelegate;

-(void)launchContentUpdate;
-(void)launchContentUpdateWithURL:(NSString *)hackersURL;

-(void)eraseFileFromDisk:(NSString *)path;
-(void)saveImageToDisk:(UIImage *)assignedImage withPath:(NSString *)path;
-(void)saveIDataToDisk:(NSData *)data withPath:(NSString *)path;
-(void)addDownloadItemRequest:(DownloadRequest *)request;
-(void)removeDownloadObserver:(id)observer;


-(HackerSpaceInfo *) spaceInfoForName:(NSString *)spaceName;

+ (ContentManager *)contentManager;

@end
