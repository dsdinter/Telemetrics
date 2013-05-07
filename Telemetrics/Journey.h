//
//  Journey.h
//  Telemetrics
//
//  Created by David Sabater on 06/05/2013.
//  Copyright (c) 2013 David Sabater. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Journey : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSDate * date;

@end
