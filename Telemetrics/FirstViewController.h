//
//  FirstViewController.h
//  Telemetrics
//
//  Created by David Sabater on 23/04/2013.
//  Copyright (c) 2013 David Sabater. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@interface FirstViewController : UIViewController <NSFetchedResultsControllerDelegate> {
    UIBarButtonItem *Start;
    NSManagedObjectContext *managedObjectContext;
    CLLocationManager *locationManager;
    BOOL isRecording,Sync;
}
@property(nonatomic, retain) IBOutlet UIBarButtonItem *Start;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *getAddressButton;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) MKPlacemark *placemark;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(IBAction)StopOrStart:(id)sender;

//Core data method to insert journey details
-(void)addJourney;

@end
