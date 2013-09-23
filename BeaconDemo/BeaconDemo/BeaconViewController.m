#import "BeaconViewController.h"

@interface BeaconViewController ()

@end

@implementation BeaconViewController
{
    CLLocationManager *locationManager;
}

- (void)loadView
{
    locationManager = [[CLLocationManager alloc] init];

    [super loadView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    locationManager.delegate = self;
    
    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"BeaconUUID"];
    NSInteger major = [[NSUserDefaults standardUserDefaults] integerForKey:@"BeaconMajor"];
    NSInteger minor = [[NSUserDefaults standardUserDefaults] integerForKey:@"BeaconMinor"];
    
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] identifier:BEACON_ID];
    
    region = [locationManager.monitoredRegions member:region];
    
    if(region)
    {
        self.monitoringSwitch.on = YES;
        
        self.uuidLabel.text = [region.proximityUUID UUIDString];
        self.majorLabel.text = [region.major stringValue];
        self.minorLabel.text = [region.minor stringValue];
        
        [locationManager requestStateForRegion:region];
    }
    else
    {
        self.monitoringSwitch.on = NO;
        
        self.uuidLabel.text = uuid;
        self.majorLabel.text = [NSString stringWithFormat:@"%d", major];
        self.minorLabel.text = [NSString stringWithFormat:@"%d", minor];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    locationManager.delegate = nil;
}

- (IBAction)monitoringAction:(id)sender
{
    NSString *uuid = [[NSUserDefaults standardUserDefaults] stringForKey:@"BeaconUUID"];
    
    if(!self.monitoringSwitch.on)
    {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] identifier:BEACON_ID];
        
        region = [locationManager.monitoredRegions member:region];
        
        if(region)
        {
            [locationManager stopMonitoringForRegion:region];
        }
    }
    else
    {
        NSInteger major = [[NSUserDefaults standardUserDefaults] integerForKey:@"BeaconMajor"];
        NSInteger minor = [[NSUserDefaults standardUserDefaults] integerForKey:@"BeaconMinor"];
        
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] major:major minor:minor identifier:BEACON_ID];
        
        region.notifyOnEntry = YES;
        region.notifyOnExit = YES;
        region.notifyEntryStateOnDisplay = YES;
        
        [locationManager startMonitoringForRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state)
    {
        case CLRegionStateInside:
            self.stateLabel.text = @"Inside";
            break;
            
        case CLRegionStateOutside:
            self.stateLabel.text = @"Outside";
            break;
            
        case CLRegionStateUnknown:
        default:
            self.stateLabel.text = @"Unknown";
            break;
    }
}

@end
