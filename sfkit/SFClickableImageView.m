#import "SFClickableImageView.h"

@implementation SFClickableImageView

- (void)mouseDown:(NSEvent*)inEvent
{
	// If we have a target and an action, send the action to the target
	
	if ( [self target] )
	{
		if ( [[self target] respondsToSelector:[self action]] )
		{
			[[self target] performSelector:[self action] withObject:self];
		}
	}
}

@end
