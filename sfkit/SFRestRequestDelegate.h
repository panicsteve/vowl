// Based on code by Adrian Kosmaczewski

@class SFRestRequest;

@protocol SFRestRequestDelegate

@required

- (void)restRequest:(SFRestRequest*)request didRetrieveData:(NSData*)data;

@optional

- (void)restRequestHasBadCredentials:(SFRestRequest*)request;
- (void)restRequest:(SFRestRequest*)request didCreateResourceAtURL:(NSString*)url;
- (void)restRequest:(SFRestRequest*)request didFailWithError:(NSError*)error;
- (void)restRequest:(SFRestRequest*)request didReceiveStatusCode:(int)statusCode;

@end
