//
//  FirstViewController.m
//  Telemetrics
//
//  Created by David Sabater on 23/04/2013.
//  Copyright (c) 2013 David Sabater. All rights reserved.
//

#import "FirstViewController.h"
#import "JourneyViewController.h"
#import "Journey.h"

#define knoRecordingSync		NSLocalizedString(@"Finished","Journey Finished")
#define kRecording	NSLocalizedString(@"Recording","Recording Journey")
#define knoRecordingnoSync	NSLocalizedString(@"Pending","Pending to sync")

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    Start.possibleTitles = [NSSet setWithObjects:kRecording, knoRecordingSync, knoRecordingnoSync, nil];
    //Initialise default settings for not recording journey and not pushing any data
    isRecording=NO;
    Sync=YES;
	// Do any additional setup after loading the view, typically from a nib.
    self.mapView.showsUserLocation = YES;
    
    self.geocoder = [[CLGeocoder alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 500;
    
    [self.locationManager startUpdatingLocation];
    
    // create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushToDetail"])
    {
        JourneyViewController *viewController = segue.destinationViewController;
        viewController.placemark = self.placemark;
    }
}
- (BOOL)SyncToServer {
    NSString *myRequestString = [[NSString alloc] initWithFormat:@"email=%@&pwd=%@&mail=%@", userName, password, mail];
    NSData *myRequestData = [ NSData dataWithBytes: [ myRequestString UTF8String ] length: [ myRequestString length ] ];
    NSMutableURLRequest *request = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString:@"http://url.com/iphone/iphone.php/?"]];
    
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody: myRequestData];
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&err];
    NSString *content = [NSString stringWithUTF8String:[returnData bytes]];
    NSLog(@"responseData: %@", content);
    
    
    NSString* responseString = [[NSString alloc] initWithData:returnData encoding:NSNonLossyASCIIStringEncoding];
    if ([content isEqualToString:responseString])
    {
        Sync = YES;
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

- (void)addJourney {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    if (!context) {
        // Handle the error.
        NSLog(@"Error initializing context");
        return;
    }
    CLLocation *location = [self.locationManager location];
    if (!location) {
        return;
    }
    // Create and configure a new instance of the Journey entity.
    Journey *journey = (Journey *)[NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    //NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    CLLocationCoordinate2D coordinate = [location coordinate];
    CLLocationSpeed speed = [location speed];
    [journey setLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
    [journey setLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
    [journey setSpeed:[NSNumber numberWithDouble:speed]];
    [journey setDate:[NSDate date]];
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        // Handle the error.
    }
}
-(IBAction)StopOrStart:(id)sender
{
	if(isRecording)
	{
		// If we're recording, then stop, push data and set the title to "Finished"
		isRecording = NO;
        Sync = NO;
		self.Start.title = knoRecordingnoSync;
        if (!Sync)
        {
            // If we are not recording, then start recording, adding journeys to core data and set the title to "Recording"
            if([self SyncToServer])
            {
                self.Start.title = knoRecordingSync;
                Sync = YES;
            }
        }
	}
    else
    {
        // If we are not recording, then start recording, adding journeys to core data and set the title to "Recording"
		isRecording = YES;
		self.Start.title = kRecording;
        [self addJourney];
    }
	
	// Inform accessibility clients that the pause/resume button has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Journey" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}


@end
