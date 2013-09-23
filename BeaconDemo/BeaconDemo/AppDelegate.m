#import "AppDelegate.h"

@implementation AppDelegate
{
    CLLocationManager *locationManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"BeaconUUID"];
    NSInteger major = [[NSUserDefaults standardUserDefaults] integerForKey:@"BeaconMajor"];
    NSInteger minor = [[NSUserDefaults standardUserDefaults] integerForKey:@"BeaconMinor"];
    if(uuid == nil)
    {
        NSLog(@"no uuid found");
        
        uuid = [[NSUUID UUID] UUIDString];
        major = 1;
        minor = 1;
        
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"BeaconUUID"];
        [[NSUserDefaults standardUserDefaults] setObject:@(major) forKey:@"BeaconMajor"];
        [[NSUserDefaults standardUserDefaults] setObject:@(minor) forKey:@"BeaconMinor"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] identifier:BEACON_ID];
    
    region = [locationManager.monitoredRegions member:region];
    
    // Stop monitoring if the region's UUID doesn't match the generated UUID
    if(region != nil && ![[region.proximityUUID UUIDString] isEqualToString:uuid])
    {
        NSLog(@"Found region uuid does not match");
        
        [locationManager stopMonitoringForRegion:region];
        region = nil;
    }
    
    if(!region)
    {
        region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] major:major minor:minor identifier:BEACON_ID];
    
        region.notifyOnEntry = YES;
        region.notifyOnExit = YES;
        region.notifyEntryStateOnDisplay = YES;
        
        [locationManager startMonitoringForRegion:region];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertBody
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    if(state == CLRegionStateInside)
    {
        notification.alertBody = @"You're inside the region";
    }
    else if(state == CLRegionStateOutside || state == CLRegionStateUnknown)
    {
        notification.alertBody = @"You're outside the region";
    }
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

@end
