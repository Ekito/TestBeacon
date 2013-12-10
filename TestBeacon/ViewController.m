//
//  ViewController.m
//  TestBeacon
//
//  Created by Arnaud Boudou on 02/12/2013.
//  Copyright (c) 2013 Arnaud Boudou. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    CLBeaconMajorValue major = 65424;
    CLBeaconMinorValue minor = 34082;
    NSString *regionIdentifier = @"com.example.identifier.ibeacon";
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:regionIdentifier];
    
    // Est censé réveiller l'application même si elle n'est pas lancée (mais pas réussi à le faire fonctionner).
    // Dans tous les cas, ça lance bien didDetermineState quand on allume l'écran et que l'application
    // est en veille (et même quand l'écran est éteint), mais rien quand l'application est fermée.
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    
    // Démarre le monitoring des régions définies
    [self.locationManager startMonitoringForRegion:self.beaconRegion];

    // Démarre le ranging des iBeacons des régions définies
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];

    // Demande l'état actuel pour les régions définies (dedans ou dehors), le monitoring de région ne réagissant
    // que lors de l'entrée ou la sortie d'une région. Ça permet d'initialiser correctement l'état de l'application
    // en fonction de la présence ou non d'un iBeacon lors du lancement de l'application.
    [self.locationManager requestStateForRegion:self.beaconRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - CLLocationManagerDelegate

-(void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if(state == CLRegionStateInside) {
        NSLog(@"Inside region");
//        UILocalNotification *notification = [[UILocalNotification alloc] init];
//        notification.alertBody = @"You entered beacon zone (via didDetermineState)";
//        notification.soundName = UILocalNotificationDefaultSoundName;
//        
//        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    } else {
        NSLog(@"Outside region");
//        UILocalNotification *notification = [[UILocalNotification alloc] init];
//        notification.alertBody = @"You left beacon zone (via didDetermineState)";
//        notification.soundName = UILocalNotificationDefaultSoundName;
//        
//        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *beacon;
    
    if([beacons count] > 0) {
        
        for (CLBeacon *beacon in beacons) {
            NSLog(@"%@ %@ %@", beacon.proximityUUID.UUIDString, beacon.major, beacon.minor);
        }
        
        beacon = [beacons firstObject];
        
        self.beaconFoundLabel.text = @"Yes";
        self.proximityUUIDLabel.text = beacon.proximityUUID.UUIDString;
        self.majorLabel.text = [NSString stringWithFormat:@"%@", beacon.major];
        self.minorLabel.text = [NSString stringWithFormat:@"%@", beacon.minor];
        self.accuracyLabel.text = [NSString stringWithFormat:@"%f", beacon.accuracy];
        if (beacon.proximity == CLProximityUnknown) {
            self.distanceLabel.text = @"Unknown Proximity";
        } else if (beacon.proximity == CLProximityImmediate) {
            self.distanceLabel.text = @"Immediate";
        } else if (beacon.proximity == CLProximityNear) {
            self.distanceLabel.text = @"Near";
        } else if (beacon.proximity == CLProximityFar) {
            self.distanceLabel.text = @"Far";
        }
        self.rssiLabel.text = [NSString stringWithFormat:@"%li", (long)beacon.rssi];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    // iPhone/iPad entered beacon zone
    // Present local notification
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"You entered beacon zone";
    notification.soundName = UILocalNotificationDefaultSoundName;

    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    // iPhone/iPad left beacon zone
    // Present local notification
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"You left beacon zone";
    notification.soundName = UILocalNotificationDefaultSoundName;

    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

@end
