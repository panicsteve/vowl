#import "SFFlickrClient.h"
#import "SFFlickrPhoto.h"
#import "SFFlickrTag.h"
#import "SFRestRequest.h"

static NSString* FLICKR_REST_URL = @"http://api.flickr.com/services/rest/";

@implementation SFFlickrClient

@synthesize apiKey;
@synthesize delegate;


- (id)initWithAPIKey:(NSString*)inAPIKey
{	
	if ( (self = [super init]) ) 
	{
		self.apiKey = inAPIKey;
	}
	return self;
}


- (void)dealloc
{
	delegate = nil;
	
	if ( requestInProgress )
	{
		[requestInProgress cancelConnection];
		[requestInProgress release];
		requestInProgress = nil;
	}

	[super dealloc];
}


- (void)cancelOperations
{
	if ( requestInProgress )
	{
		[requestInProgress cancelConnection];
		[requestInProgress release];
		requestInProgress = nil;
	}
	
	if ( download )
	{
		[download cancel];
		[download release];
		download = nil;
	}
}


- (void)download:(NSURLDownload*)download didFailWithError:(NSError*)error
{
    NSLog(@"download:didFailWithError: %@", [error description]);
}


- (void)downloadDidFinish:(NSURLDownload*)inDownload
{	
	NSAssert(download == inDownload, @"We should know about this download");
	
	NSURL* baseLocalURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
	NSString* localPath = [[baseLocalURL path] stringByAppendingPathComponent:@"vowl-tmp.jpg"];

	NSData* imageData = [NSData dataWithContentsOfFile:localPath];
	
	NSImage* image = nil;
	
	if ( imageData )
		image = [[[NSImage alloc] initWithData:imageData] autorelease];

	if ( delegate )
		[delegate flickrClient:self receivedImage:image];

	[download release];
	download = nil;
}



- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName attributes:(NSDictionary*)attributeDict
{
	if ( [elementName isEqualToString:@"photo"] )
	{	
		SFFlickrPhoto* newPhoto = [SFFlickrPhoto photoWithAttributes:attributeDict];
		[outArray addObject:newPhoto];
	}
}


- (void)requestImageForPhoto:(SFFlickrPhoto*)photo
{
	NSURL* url = [photo directURL];
	
	NSAssert(download == nil, @"No download should be in progress");

	NSURL* baseLocalURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
	NSString* localPath = [[baseLocalURL path] stringByAppendingPathComponent:@"vowl-tmp.jpg"];
	
	download = [[NSURLDownload alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
	[download setDestination:localPath allowOverwrite:YES];
	
	// Download is released in delegate callback downloadDidFinish: when it finishes
}


- (void)requestPhotosWithTags:(NSArray*)tags intoArray:(NSMutableArray*)array perPage:(NSNumber*)perPage page:(NSNumber*)page
{
	if ( [tags count] == 0 )
		return;
	
	NSAssert(requestInProgress == nil, @"Request should not be in progress at this time");
	
	requestInProgress = [[SFRestRequest alloc] init];
	requestInProgress.delegate = self;
	
	outArray = array;
	
	NSURL* url = [NSURL URLWithString:FLICKR_REST_URL];

	NSMutableString* tagString = [NSMutableString string];
	BOOL first = YES;
	
	for ( SFFlickrTag* tag in tags )
	{
		if ( first )
			first = NO;
		else
			[tagString appendString:@","];
			
		[tagString appendString:tag.name];
	}

	NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:
					@"flickr.photos.search", @"method", 
					apiKey, @"api_key", 
					tagString, @"tags", 
					@"1", @"content_type", 
					[perPage stringValue], @"per_page", 
					[page stringValue], @"page", 
					nil];

    [requestInProgress sendRequestTo:url usingVerb:@"POST" withParameters:parameters];
	
	// requestInProgress is released in delegate callback restRequest:didRetrieveData:
}


- (void)restRequest:(SFRestRequest*)request didFailWithError:(NSError*)error
{
	NSAssert(request == requestInProgress, @"Request calling this should be the known request in progress");

    NSLog(@"restRequest:didFailWithError: %@", [error description]);

	if ( delegate )
		[delegate flickrClientReceivedPhotos:self];
		
	[requestInProgress release];
	requestInProgress = nil;
}


- (void)restRequest:(SFRestRequest*)request didRetrieveData:(NSData*)data
{
	NSAssert(request == requestInProgress, @"Request calling this should be the known request in progress");
		
	NSXMLParser* parser = [[[NSXMLParser alloc] initWithData:data] autorelease];
	[parser setDelegate:self];
	[parser parse];
		
	if ( delegate )
		[delegate flickrClientReceivedPhotos:self];
		
	[requestInProgress release];
	requestInProgress = nil;
}


@end
