//
//  SecondViewController.h
//  Telemetrics
//
//  Created by David Sabater on 23/04/2013.
//  Copyright (c) 2013 David Sabater. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class GraphView;
@class AccelerometerFilter;

@interface SecondViewController : UIViewController<UIAccelerometerDelegate>
{
	GraphView *unfiltered;
	GraphView *filtered;
	UIBarButtonItem *pause;
	UILabel *filterLabel;
	AccelerometerFilter *filter;
	BOOL isPaused, useAdaptive;
}

@property(nonatomic, retain) IBOutlet GraphView *unfiltered;
@property(nonatomic, retain) IBOutlet GraphView *filtered;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *pause;
@property(nonatomic, retain) IBOutlet UILabel *filterLabel;

-(IBAction)pauseOrResume:(id)sender;
-(IBAction)filterSelect:(id)sender;
-(IBAction)adaptiveSelect:(id)sender;
@end
