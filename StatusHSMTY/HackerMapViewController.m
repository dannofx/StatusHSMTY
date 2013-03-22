//
//  MapKitDisplayViewController.m
//  MapKitDisplay
//
//  Created by Chakra on 12/07/10.
//  Copyright Chakra Interactive Pvt Ltd 2010. All rights reserved.
//

#import "HackerMapViewController.h"
#import "HackerSpaceAnnotation.h"

@interface HackerMapViewController()
{
    HackerSpaceAnnotation *spaceAnnotation;

}
@end

@implementation HackerMapViewController
@synthesize zoneMapView;
@synthesize titleLocation;
@synthesize subtitle;
@synthesize longitude;
@synthesize latitude;

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
	
	[zoneMapView setMapType:MKMapTypeStandard];
	[zoneMapView setZoomEnabled:YES];
	[zoneMapView setScrollEnabled:YES];
	MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };

	region.center.latitude = self.latitude ;
	region.center.longitude = self.longitude;
	region.span.longitudeDelta = 0.01f;
	region.span.latitudeDelta = 0.01f;
	[zoneMapView setRegion:region animated:YES]; 
	
	[zoneMapView setDelegate:self];
	
    spaceAnnotation = [[HackerSpaceAnnotation alloc] init]; 
	spaceAnnotation.title = self.titleLocation;
	spaceAnnotation.subtitle = self.subtitle;
	spaceAnnotation.coordinate = region.center; 
	[zoneMapView addAnnotation:spaceAnnotation];
}



-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:
 (id <MKAnnotation>)annotation {
	MKPinAnnotationView *pinView = nil; 
	if(annotation != zoneMapView.userLocation) 
	{
		static NSString *defaultPinID = @"com.hackerspace.pin";
		pinView = (MKPinAnnotationView *)[zoneMapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
		if ( pinView == nil ) pinView = [[MKPinAnnotationView alloc]
										  initWithAnnotation:annotation reuseIdentifier:defaultPinID];

		pinView.pinColor = MKPinAnnotationColorRed; 
		pinView.canShowCallout = YES;
		pinView.animatesDrop = YES;
		} 
	else {
		[zoneMapView.userLocation setTitle:@"My place"];
	}
	return pinView;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - User actions
-(IBAction)hideController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)openMapsApp:(id)sender
{

    //first create latitude longitude object
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.latitude,self.longitude);
    
    //create MKMapItem out of coordinates
    MKPlacemark* placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem* destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
    
    if([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)])
    {
        //using iOS6 native maps app
        [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
        
    } else{
        
        //using iOS 5 which has the Google Maps application
        NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=Current+Location&daddr=%f,%f", latitude, longitude];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
}



#pragma mark - Dealloc
- (void)dealloc {
	zoneMapView=nil;
    spaceAnnotation=nil;
}

@end
