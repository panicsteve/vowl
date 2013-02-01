#import "SFFlickrPhoto.h"

@implementation SFFlickrPhoto

@synthesize farm;
@synthesize photoID;
@synthesize isFamily;
@synthesize isFriend;
@synthesize isPublic;
@synthesize owner;
@synthesize secret;
@synthesize server;
@synthesize title;


+ (id)photoWithAttributes:(NSDictionary*)attrs
{
	return [[(SFFlickrPhoto*)[SFFlickrPhoto alloc] initWithAttributes:attrs] autorelease];
}


- (id)initWithAttributes:(NSDictionary*)attrs
{
	if ( (self = [super init]) )
	{
		self.farm = [[attrs objectForKey:@"farm"] intValue];
		self.photoID = [attrs objectForKey:@"id"];
		self.isFamily = [[attrs objectForKey:@"isFamily"] boolValue];
		self.isFriend = [[attrs objectForKey:@"isFriend"] boolValue];
		self.isPublic = [[attrs objectForKey:@"isPublic"] boolValue];
		self.owner = [attrs objectForKey:@"owner"];
		self.secret = [attrs objectForKey:@"secret"];
		self.server = [attrs objectForKey:@"server"];
		self.title = [attrs objectForKey:@"title"];
	}
	return self;
}


- (void)dealloc
{
	[cachedDirectURL release];
	[cachedPageURL release];
	
	[photoID release];
	[owner release];
	[secret release];
	[server release];
	[title release];

	[super dealloc];
}


- (NSString*)description
{
	NSString* outString = [NSString stringWithFormat:@"farm = %d,\nphotoID = %@,\nisFamily = %d,\nisFriend = %d,\nisPublic = %d,\nowner = %@,\nsecret = %@,\nserver = %@,\ntitle = %@,\n", farm, photoID, isFamily, isFriend, isPublic, owner, secret, server, title];
	
	return outString;
}



- (NSURL*)directURL
{
	if ( cachedDirectURL )
		return cachedDirectURL;
		
	NSString* urlString = [NSString stringWithFormat:@"http://farm%d.static.flickr.com/%@/%@_%@.jpg", farm, server, photoID, secret];
	cachedDirectURL = [[NSURL URLWithString:urlString] retain]; 	
	
	return cachedDirectURL;
}


- (NSURL*)pageURL
{
	if ( cachedPageURL )
		return cachedPageURL;
		
	NSString* urlString = [NSString stringWithFormat:@"http://flickr.com/photos/%@/%@/", owner, photoID];
	cachedPageURL = [[NSURL URLWithString:urlString] retain];
	
	return cachedPageURL;
}

@end
