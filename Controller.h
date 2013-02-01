#import "SFFlickrClientDelegate.h"

@class PrefsWindowController;
@class SFFlickrClient;
@class SFFlickrPhoto;
@class SFTransitioningImageView;
@class VowlWindow;

@interface Controller : NSObject <SFFlickrClientDelegate>
{
	IBOutlet VowlWindow* window;
	
	PrefsWindowController* preferencesWindowController;

	SFTransitioningImageView* imageView;
	NSProgressIndicator* progressIndicator;
    NSTextField* statusField;
    
	SFFlickrClient* flickrClient;
	
	NSMutableArray* photos;
	SFFlickrPhoto* currentPhoto;
	
	NSTimer* updateTimer;
    NSUInteger page;

    BOOL waitingForFlickr;
}

- (IBAction)bringVowlWindowToFront:(id)sender;
- (IBAction)showPreferences:(id)sender;

@end
