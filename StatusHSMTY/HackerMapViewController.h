//
//  MapKitDisplayViewController.h
//  MapKitDisplay
//
//  Created by Chakra on 12/07/10.
//  Copyright Chakra Interactive Pvt Ltd 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class HackerSpaceAnnotation;

@interface HackerMapViewController : UIViewController <MKMapViewDelegate> {
	
	IBOutlet MKMapView *zoneMapView;
}
@property (nonatomic, retain) IBOutlet MKMapView *zoneMapView;
@property (nonatomic) CGFloat longitude;
@property (nonatomic) CGFloat latitude;
@property (nonatomic,retain) NSString * title;
@property (nonatomic,retain) NSString * subtitle;


-(IBAction)hideController:(id)sender;
-(IBAction)openMapsApp:(id)sender;
@end

