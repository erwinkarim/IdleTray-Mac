#import "BackgroundView.h"
#import "StatusItemView.h"

@class PanelController;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate>
{
    BOOL _hasActivePanel;
    __unsafe_unretained BackgroundView *_backgroundView;
    __unsafe_unretained id<PanelControllerDelegate> _delegate;
    //__unsafe_unretained NSSearchField *_searchField;
    //__unsafe_unretained NSTextField *_textField;
    __strong NSTextField *_fireworksAddressField;
}

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;
@property (unsafe_unretained) IBOutlet NSTextField *statusField;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;
- (IBAction)quitApplication:(id)sender;
- (IBAction)testAddress:(id)sender;
@property (strong) IBOutlet NSTextField *fireworksAddressField;

@end
