#import <UIKit/UIKit.h>

@interface ConfigurationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UITextField *majorTextEntry;
@property (weak, nonatomic) IBOutlet UITextField *minorTextEntry;
@property (weak, nonatomic) IBOutlet UISwitch *notifyOnExitSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *notifyOnEntrySwitch;

- (IBAction)regenerateUUIDAction:(id)sender;

@end
