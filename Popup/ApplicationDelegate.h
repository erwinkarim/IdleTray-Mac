#import "MenubarController.h"
#import "PanelController.h"

@interface ApplicationDelegate : NSObject <NSApplicationDelegate, PanelControllerDelegate>

@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong, readonly) PanelController *panelController;
@property (nonatomic, strong) NSTimer *timer;

- (void)onTick;
- (IBAction)togglePanel:(id)sender;
- (int64_t) SystemIdleTime;

@end
