#import "ApplicationDelegate.h"

@implementation ApplicationDelegate

@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;
@synthesize timer = _timer;

#pragma mark -

- (void)dealloc
{
    [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
    [self removeObserver:self forKeyPath:@"updateFields"];
}

#pragma mark -

void *kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContextActivePanel) {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // Install icon into the menu bar
    self.menubarController = [[MenubarController alloc] init];
    
    //set timer to send updates to server
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 600.0
                                target: self
                                selector:@selector(onTick)
                                userInfo: nil repeats:YES];
    

}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    return NSTerminateNow;
}

#pragma mark - Actions

- (IBAction)togglePanel:(id)sender
{
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
}

#pragma mark - Public accessors

- (PanelController *)panelController
{
    if (_panelController == nil) {
        _panelController = [[PanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];

    }
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller
{
    return self.menubarController.statusItemView;
}

#pragma mark - Timer stuff
/**
 Returns the number of seconds the machine has been idle or -1 if an error occurs.
 The code is compatible with Tiger/10.4 and later (but not iOS).
 */
-(int64_t) SystemIdleTime{
    int64_t idlesecs = -1;
    io_iterator_t iter = 0;
    if (IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOHIDSystem"), &iter) == KERN_SUCCESS) {
        io_registry_entry_t entry = IOIteratorNext(iter);
        if (entry) {
            CFMutableDictionaryRef dict = NULL;
            if (IORegistryEntryCreateCFProperties(entry, &dict, kCFAllocatorDefault, 0) == KERN_SUCCESS) {
                CFNumberRef obj = CFDictionaryGetValue(dict, CFSTR("HIDIdleTime"));
                if (obj) {
                    int64_t nanoseconds = 0;
                    if (CFNumberGetValue(obj, kCFNumberSInt64Type, &nanoseconds)) {
                        idlesecs = (nanoseconds >> 20); // Divide by 10^6 to convert from nanoseconds to miliseconds.
                    }
                }
                CFRelease(dict);
            }
            IOObjectRelease(entry);
        }
        IOObjectRelease(iter);
    }
    return idlesecs;
}

-(void)onTick{
    [self.panelController.statusField setStringValue:@"sending data to server"];
    
    //get required info
    int64_t idleTime = [self SystemIdleTime];
    NSString *hostname = [[NSHost currentHost] name];
    NSString *username = NSUserName();
    NSURL *pathToSend = [[NSURL alloc] initWithScheme:@"http" host:[[NSUserDefaults standardUserDefaults] stringForKey:@"fireworksAddress"] path:[NSString stringWithFormat:@"/idle_user/report?host=%@&user=%@&idle=%lld",hostname,username,idleTime]];
    
    //send info to the server
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:pathToSend];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    //update status
    if(theConnection){
        //connection successful
        [self.panelController.statusField setStringValue:@"succesfully send to server"];
    }else{
        //connection failed
        [self.panelController.statusField setStringValue:@"failed to send to server"];
    }
    
}

@end
