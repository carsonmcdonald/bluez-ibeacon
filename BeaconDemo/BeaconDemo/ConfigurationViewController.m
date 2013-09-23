#import "ConfigurationViewController.h"

#import <CoreLocation/CoreLocation.h>

@interface ConfigurationViewController ()

@end

@implementation ConfigurationViewController
{
    CLLocationManager *locationManager;
}

- (void)loadView
{
    locationManager = [[CLLocationManager alloc] init];
    
    [super loadView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"BeaconUUID"];
    NSInteger major = [[NSUserDefaults standardUserDefaults] integerForKey:@"BeaconMajor"];
    NSInteger minor = [[NSUserDefaults standardUserDefaults] integerForKey:@"BeaconMinor"];
    
    self.uuidLabel.text = uuid;
    self.majorTextEntry.text = [NSString stringWithFormat:@"%d", major];
    self.minorTextEntry.text = [NSString stringWithFormat:@"%d", minor];
    
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] identifier:BEACON_ID];
    
    region = [locationManager.monitoredRegions member:region];
    
    if(region)
    {
        self.notifyOnEntrySwitch.on = region.notifyOnEntry;
        self.notifyOnExitSwitch.on = region.notifyOnExit;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSString *oldUUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"BeaconUUID"];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.uuidLabel.text forKey:@"BeaconUUID"];
    [[NSUserDefaults standardUserDefaults] setObject:@([self.majorTextEntry.text intValue]) forKey:@"BeaconMajor"];
    [[NSUserDefaults standardUserDefaults] setObject:@([self.minorTextEntry.text intValue]) forKey:@"BeaconMinor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:oldUUID] identifier:BEACON_ID];
    
    region = [locationManager.monitoredRegions member:region];
    
    if(region)
    {
        [locationManager stopMonitoringForRegion:region];
    }
    
    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"BeaconUUID"];
    NSInteger major = [[NSUserDefaults standardUserDefaults] integerForKey:@"BeaconMajor"];
    NSInteger minor = [[NSUserDefaults standardUserDefaults] integerForKey:@"BeaconMinor"];
    
    region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] major:major minor:minor identifier:BEACON_ID];
    
    region.notifyOnEntry = self.notifyOnEntrySwitch.on;
    region.notifyOnExit = self.notifyOnExitSwitch.on;
    region.notifyEntryStateOnDisplay = YES;
    
    [locationManager startMonitoringForRegion:region];
}

- (IBAction)regenerateUUIDAction:(id)sender
{
    self.uuidLabel.text = [[NSUUID UUID] UUIDString];
}

@end
