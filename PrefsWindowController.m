#import "PrefsWindowController.h"

@implementation PrefsWindowController

- (void)windowDidLoad
{
	// Prefs window came up; Check IB connections
	
	NSAssert(flickrTagsArrayController != nil, @"flickrTagsArrayController shouldn't be nil");
	NSAssert(tagsTableView != nil, @"tagsTableView shouldn't be nil");

	// Populate Flickr tags table

	NSData* flickrTagsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"flickrTags"];
	
	if ( flickrTagsData )
	{
		NSArray* tags = [NSKeyedUnarchiver unarchiveObjectWithData:flickrTagsData];
		if ( tags )
		{
			NSMutableArray* mutableTags = [[tags mutableCopy] autorelease];
			[flickrTagsArrayController setContent:mutableTags];		
		}
	}
	
	// Observe changes to the Flickr tags list
	
	[flickrTagsArrayController addObserver:self forKeyPath:@"arrangedObjects" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

	[flickrTagsArrayController addObserver:self forKeyPath:@"arrangedObjects.name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}


- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id) object change:(NSDictionary*)change context:(void*)context
{
	if ( object == flickrTagsArrayController )
	{
		// Flickr tags list changed; Get new array
		
		NSArray* tags = [flickrTagsArrayController arrangedObjects];
		NSData* archivedTags = [NSKeyedArchiver archivedDataWithRootObject:tags];
		
		// Store in prefs
		
		[[NSUserDefaults standardUserDefaults] setObject:archivedTags forKey:@"flickrTags"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		// Send out notification that tags changed
		
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"TagListDidChange" object:nil]];
	}
}

@end