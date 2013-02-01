#import "SFFlickrTag.h"

@implementation SFFlickrTag

@synthesize name;

+ (id)tagWithName:(NSString*)inName
{
	SFFlickrTag* outTag = [[[SFFlickrTag alloc] init] autorelease];
	outTag.name = inName;
	return outTag;
}


- (id)init
{
	if ( (self = [super init]) != nil )
	{
		self.name = NSLocalizedString(@"tag", @"");
	}
	
	return self;
}


- (id)initWithCoder:(NSCoder*)decoder
{
	if ( (self = [super init]) != nil )
	{
		self.name = [decoder decodeObjectForKey:@"name"];
	}
	
	return self;
}


- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeObject:name forKey:@"name"];
}


- (void)dealloc
{
	[name release];
	[super dealloc];
}


- (NSString*)description
{
	return name;
}

@end
