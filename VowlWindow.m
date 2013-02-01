#import "VowlWindow.h"

#define kDefaultStyleMask (NSHUDWindowMask | NSTitledWindowMask | NSUtilityWindowMask | NSClosableWindowMask | NSResizableWindowMask)

@implementation VowlWindow

- (id)initWithContentRect:(NSRect)contentRect
{
    if ( (self = [super initWithContentRect:contentRect styleMask:kDefaultStyleMask backing:NSBackingStoreBuffered defer:NO screen:nil]) ) 
    {
        savedBackgroundColor = [[self backgroundColor] copy];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


- (void)showChrome:(BOOL)flag
{
    if ( [NSApp isActive] && flag == NO )
        return;
        
    if ( flag )
    {
        [self setStyleMask:kDefaultStyleMask];
        [self setTitle:@"Vowl"];
        [self setFrameAutosaveName:@"MainWindow"];
    }
    else
    {
        [NSWindow removeFrameUsingName:@"MainWindowNoChrome"];
        [self setFrameAutosaveName:@"MainWindowNoChrome"];
        [self setStyleMask:NSHUDWindowMask];
    }

    [[self contentView] setNeedsDisplay:YES];
}

@end
