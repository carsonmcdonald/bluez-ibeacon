#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

@interface BeaconViewController : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (weak, nonatomic) IBOutlet UISwitch *monitoringSwitch;

- (IBAction)monitoringAction:(id)sender;

@end
