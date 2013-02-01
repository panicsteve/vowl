#import "Controller.h"
#import "PrefsWindowController.h"
#import "SFFlickrClient.h"
#import "SFFlickrPhoto.h"
#import "SFFlickrTag.h"
#import "SFTransitioningImageView.h"
#import "VowlWindow.h"

static NSString* FLICKR_API_KEY = @"your-key-here";


@interface Controller ()

- (void)requestPhotos;
- (void)setWindowLevel;

@end


@implementation Controller

+ (void)initialize
{
	// Set up default values for prefs
	
	NSArray* defaultTags = [NSArray arrayWithObjects:
					[SFFlickrTag tagWithName:@"dog"], 
					[SFFlickrTag tagWithName:@"cat"], 
					[SFFlickrTag tagWithName:@"chicken"], 
					nil];
					
	NSData* archivedDefaultTags = [NSKeyedArchiver archivedDataWithRootObject:defaultTags];

	NSDictionary* defaults = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSNumber numberWithInt:15], @"delayBetweenPhotos",
					archivedDefaultTags, @"flickrTags",
					[NSNumber numberWithBool:NO], @"floatAboveOtherWindows",
					nil];
					
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)applicationDidBecomeActive:(NSNotification*)notification
{
    [window showChrome:YES];
}


- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
	// Register for notification when the user changes prefs
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagListDidChange:) name:@"TagListDidChange" object:nil];

	[[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"floatAboveOtherWindows" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

	// Create window
    
    NSRect contentRect = NSMakeRect(150, 350, 300, 300);    
    window = [[VowlWindow alloc] initWithContentRect:contentRect];
    
    [window setTitle:@"Vowl"];
    [window setFrameAutosaveName:@"MainWindow"];
    [window setFrameUsingName:@"MainWindow"];
    [window setExcludedFromWindowsMenu:YES];
    [window setHidesOnDeactivate:NO];
    [window setMinSize:NSMakeSize(150, 150)];

    NSView* contentView = [window contentView];
    [contentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    NSRect trackingAreaRect = [contentView frame];

    trackingAreaRect.origin.x -= 100.0;
    trackingAreaRect.size.width += 200.0;
    trackingAreaRect.origin.y -= 100.0;
    trackingAreaRect.size.height += 200.0;
    
    NSTrackingArea* trackingArea = [[[NSTrackingArea alloc] initWithRect:trackingAreaRect options:NSTrackingActiveAlways | NSTrackingMouseEnteredAndExited | NSTrackingInVisibleRect owner:self userInfo:nil] autorelease];
    [contentView addTrackingArea:trackingArea];

	// Add transitioning imageView to window

	imageView = [[[SFTransitioningImageView alloc] initWithFrame:[[window contentView] frame]] autorelease];
	[imageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	[imageView setTarget:self];
	[imageView setAction:@selector(imageViewClicked:)];
	[contentView addSubview:imageView];
			
	// Add progress indicator last, so it's on top of everything else
			
	progressIndicator = [[[NSProgressIndicator alloc] initWithFrame:NSMakeRect(8, 8, 16, 16)] autorelease];
	[progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
	[progressIndicator setDisplayedWhenStopped:NO];
	[progressIndicator setControlSize:NSSmallControlSize];
	[contentView addSubview:progressIndicator];
    
    // Status field
    
    statusField = [[[NSTextField alloc] initWithFrame:NSMakeRect(28, 2, 250, 22)] autorelease];
    [statusField setEditable:NO];
    [statusField setBordered:NO];
    [statusField setDrawsBackground:NO];
    [statusField setStringValue:@""];
    [contentView addSubview:statusField];

	// Create the Flickr client and kick off a search

	if ( [FLICKR_API_KEY isEqualToString:@"your-key-here"] )
	{
		NSRunAlertPanel(@"Flickr API key missing", @"Please replace FLICKR_API_KEY in the source code with your own Flickr API key.", @"OK", nil, nil);
	}

	flickrClient = [[SFFlickrClient alloc] initWithAPIKey:FLICKR_API_KEY];
	flickrClient.delegate = self;

    page = 1;
    
	[self requestPhotos];
    
	// Set floating/non-floating

	[self setWindowLevel];
    [window showChrome:NO];

	[window makeKeyAndOrderFront:self];
}


- (void)applicationDidResignActive:(NSNotification*)notification
{
    [window showChrome:NO];
}


- (IBAction)bringVowlWindowToFront:(id)sender
{
    [window makeKeyAndOrderFront:self];
}


- (void)downloadNextPhoto
{
	// Show spinner
	
	[progressIndicator startAnimation:self];

	if ( [photos count] > 0 )
	{
		// Pull the next photo from the queue and request its image
		
		[currentPhoto release];
		
		currentPhoto = [[photos objectAtIndex:0] retain];
		[photos removeObjectAtIndex:0];
		
		[flickrClient requestImageForPhoto:currentPhoto];
	}
	else 
	{
		// Ran out of photos; do a fresh search
		
        [photos release];
        photos = nil;
        
		[self requestPhotos];
	}
}


- (void)flickrClientReceivedPhotos:(SFFlickrClient*)flickrClient 
{	
	if ( [photos count] == 0 )
    {
        // Error? Try restarting from page 1
        
        [photos release];
        photos = nil;
	
        page = 1;

        if ( waitingForFlickr )
            [statusField setStringValue:@"No photos found. Temporary Flickr error?"];

        [progressIndicator stopAnimation:self];
        [self performSelector:@selector(requestPhotos) withObject:nil afterDelay:5.0];
	}
    else
    {
        waitingForFlickr = NO;
        [statusField setStringValue:@""];
        
        // Pull the next one down
                    
        [self downloadNextPhoto];
    }
}


- (void)flickrClient:(SFFlickrClient*)flickrClient receivedImage:(NSImage*)image
{	
	// Got an image downloaded from Flickr; Show it
	
	if ( image )
    {
		[imageView transitionToImage:image];
	}
    
	// Reset the timer for the next update
	
	NSAssert(updateTimer == nil, @"updateTimer should not be in use at this time");
	
	float delay = [[[NSUserDefaults standardUserDefaults] objectForKey:@"delayBetweenPhotos"] floatValue];
	updateTimer = [[NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(updateTimerFired:) userInfo:nil repeats:NO] retain];

	// Stop spinner
	
	[progressIndicator stopAnimation:self];
}


- (void)imageViewClicked:(id)sender
{
	// Bring up the Flickr page for this photo
	
	if ( currentPhoto )
	{
		NSURL* url = [currentPhoto pageURL];
		[[NSWorkspace sharedWorkspace] openURL:url];
	}
}


- (void)mouseEntered:(NSEvent*)e
{
    [window showChrome:YES];
    [self setWindowLevel];
}


- (void)mouseExited:(NSEvent*)e
{
    [window showChrome:NO];
    [self setWindowLevel];
}


- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id) object change:(NSDictionary*)change context:(void*)context
{
	// User changed a pref
	
	if ( [keyPath isEqualToString:@"floatAboveOtherWindows"] )
	{
		// Change window float status
		
		[self setWindowLevel];
	}
}


- (void)requestPhotos
{
    waitingForFlickr = YES;

	// Start spinner
		
	[progressIndicator startAnimation:self];

	NSAssert(photos == nil, @"Expected photos array to be unallocated");
	photos = [[NSMutableArray alloc] init];

	// Ask Flickr for photos matching desired tags

	NSData* flickrTagsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"flickrTags"];
	
	if ( flickrTagsData )
	{
		NSArray* tags = [NSKeyedUnarchiver unarchiveObjectWithData:flickrTagsData];

		if ( tags )
        {
            NSNumber* perPage = [NSNumber numberWithInt:100];
            NSNumber* pageNum = [NSNumber numberWithUnsignedInteger:page];
            
			[flickrClient requestPhotosWithTags:tags intoArray:photos perPage:perPage page:pageNum];

            ++page;            
        }
	}
}


- (void)setWindowLevel
{
	// Make the window either float or not float depending on user pref
	
	BOOL floatAboveOtherWindows = [[[NSUserDefaults standardUserDefaults] objectForKey:@"floatAboveOtherWindows"] boolValue];
    [window setFloatingPanel:floatAboveOtherWindows];
//	[window setLevel:floatAboveOtherWindows ? NSModalPanelWindowLevel : NSNormalWindowLevel];
}


- (IBAction)showPreferences:(id)sender
{
	// Show preferences window, creating it first if necessary
	
	if ( !preferencesWindowController )
		preferencesWindowController = [[PrefsWindowController alloc] initWithWindowNibName:@"PrefsWindow"];

	[preferencesWindowController showWindow:self];
}


- (void)tagListDidChange:(NSNotification*)notification
{	
	// User modified the list of tags
	
	// Stop updating
	
	[updateTimer invalidate];
	[updateTimer release];
	updateTimer = nil;

	// Cancel whatever's going on in the background

	[flickrClient cancelOperations];

	// Release the current photo queue

	[currentPhoto release];
	currentPhoto = nil;
	
	[photos release];
	photos = nil;
	
	// Do a fresh search
    
    page = 1;

	[self requestPhotos];
}


- (void)updateTimerFired:(NSTimer*)timer
{	
	// Timer went off for an update
	
	// Release the current timer

	[updateTimer invalidate];
	[updateTimer release];
	updateTimer = nil;
	
	// Pull down the next photo
	
	[self downloadNextPhoto];
}

@end
