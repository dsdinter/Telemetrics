//
//  FirstViewController.m
//  Telemetrics
//
//  Created by David Sabater on 23/04/2013.
//  Copyright (c) 2013 David Sabater. All rights reserved.
//

#import "FirstViewController.h"
#import "PlacemarkViewController.h"
#import "Journey.h"

@interface FirstViewController ()


@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *getAddressButton;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) MKPlacemark *placemark;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) CLLocationManager *locationManager;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.mapView.showsUserLocation = YES;
    
    self.geocoder = [[CLGeocoder alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 500;
    
    [self.locationManager startUpdatingLocation];
    //addEvent();
    
    // create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushToDetail"])
    {
        PlacemarkViewController *viewController = segue.destinationViewController;
        viewController.placemark = self.placemark;
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self.geocoder reverseGeocodeLocation:self.mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        _placemark = [placemarks objectAtIndex:0];
        
        // we have received our current location, so enable the "Get Current Address" button
        [self.getAddressButton setEnabled:YES];
    }];
}

- (void)addEvent {
    
    CLLocation *location = [self.locationManager location];
    if (!location) {
        return;
    }
    // Create and configure a new instance of the Event entity.
    Journey *journey = (Journey *)[NSEntityDescription insertNewObjectForEntityForName:@"Journey" inManagedObjectContext:managedObjectContext];
    
    CLLocationCoordinate2D coordinate = [location coordinate];
    [journey setLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
    [journey setLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
    [journey setDate:[NSDate date]];
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        // Handle the error.
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
