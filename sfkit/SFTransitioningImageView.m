#import "SFClickableImageView.h"
#import "SFTransitioningImageView.h"

@implementation SFTransitioningImageView

- (id)initWithFrame:(NSRect)frame 
{
	if ( (self = [super initWithFrame:frame]) ) 
	{
		imageView1 = [[[SFClickableImageView alloc] initWithFrame:frame] autorelease];
		[imageView1 setImageScaling:NSImageScaleProportionallyUpOrDown];
		[imageView1 setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[imageView1 setAlphaValue:0.0];
		[self addSubview:imageView1];

		imageView2 = [[[SFClickableImageView alloc] initWithFrame:frame] autorelease];
		[imageView2 setImageScaling:NSImageScaleProportionallyUpOrDown];
		[imageView2 setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[imageView2 setAlphaValue:0.0];
        [self addSubview:imageView2];
		
		currentImageView = imageView1;
	}
	return self;
}


- (void)setAction:(SEL)inAction
{
	[imageView1 setAction:inAction];
	[imageView2 setAction:inAction];
}


- (void)setTarget:(id)inTarget
{
	[imageView1 setTarget:inTarget];
	[imageView2 setTarget:inTarget];
}


- (void)transitionToImage:(NSImage*)newImage
{
	SFClickableImageView* nextImageView;
	
	if ( currentImageView == imageView1 ) 
		nextImageView = imageView2;
	else
		nextImageView = imageView1;

	[nextImageView setImage:newImage];
	[[nextImageView animator] setAlphaValue:1.0];
	[[currentImageView animator] setAlphaValue:0.0];
	
	currentImageView = nextImageView;
}


@end
