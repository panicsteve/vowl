// Based on code by Adrian Kosmaczewski

#import "SFRestRequestDelegate.h"

@interface SFRestRequest : NSObject 
{
@private
    BOOL asynchronous;
    NSURLConnection* conn;
    NSObject<SFRestRequestDelegate>* delegate;
    NSString* mimeType;
    NSString* password;
    NSMutableData* receivedData;
    NSString* username;
}

@property (nonatomic) BOOL asynchronous;
@property (nonatomic, assign) NSObject<SFRestRequestDelegate>* delegate; // Do not retain delegates!
@property (nonatomic, copy) NSString* mimeType;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, readonly) NSData* receivedData;
@property (nonatomic, copy) NSString* username;

- (void)cancelConnection;

- (void)sendRequestTo:(NSURL*)url usingVerb:(NSString*)verb withParameters:(NSDictionary*)parameters;

- (void)uploadData:(NSData*)data toURL:(NSURL*)url;

- (NSDictionary*)responseAsPropertyList;
- (NSString*)responseAsText;

@end

