/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
***/
//
//  ASConnection.m
//  SimpleDownload
//
//  Created by Matt Drance on 3/1/10.
//  Copyright 2010 Bookhouse Software, LLC. All rights reserved.
//

#import "ASConnection.h"

/////////////////////////////////////////////////////////////////////////////////////
@interface ASConnection ()

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSURLRequest *urlRequest;
@property (nonatomic, copy) NSURL *downloadFileURL;
@property (nonatomic, retain) NSFileHandle* downloadStream;
@property (nonatomic, retain) NSMutableData *downloadData;
@property (nonatomic, retain) NSDictionary *responseHeaderFields;
@property (nonatomic, assign) NSInteger contentLength;
@property (nonatomic, assign) float previousMilestone;
@property (nonatomic, copy) ASConnectionProgressBlock downloadProgressBlock;
@property (nonatomic, copy) ASConnectionProgressBlock uploadProgressBlock;
@property (nonatomic, copy) ASConnectionCompletionBlock completionBlock;
@property (nonatomic, assign) float uploadPercentComplete;

@end

/////////////////////////////////////////////////////////////////////////////////////
@implementation ASConnection

@synthesize url;
@synthesize urlRequest;
@synthesize downloadFileURL;
@synthesize connection;
@synthesize connectionError;
@synthesize contentLength;
@synthesize fileSize;
@synthesize downloadData;
@synthesize responseHeaderFields;
@synthesize downloadStream;
@synthesize progressThreshold;
@synthesize previousMilestone;

@synthesize downloadProgressBlock;
@synthesize uploadProgressBlock;
@synthesize completionBlock;
@synthesize uploadPercentComplete;

@synthesize uploadFileURL;
@synthesize uploadStream;

/////////////////////////////////////////////////////////////////////////////////////
/* RichS: Removed for ARC
- (void)dealloc {

    [url release], url = nil;
    [urlRequest release], urlRequest = nil;
    [connection cancel], [connection release], connection = nil;
    [downloadData release], downloadData = nil;
    [progressBlock release], progressBlock = nil;
    [completionBlock release], completionBlock = nil;
    
    [super dealloc];
}
*/

/////////////////////////////////////////////////////////////////////////////////////
+ (id)connectionWithRequest:(NSURLRequest *)request
      downloadProgressBlock:(ASConnectionProgressBlock)downloadProgress
        uploadProgressBlock:(ASConnectionProgressBlock)uploadProgress
            completionBlock:(ASConnectionCompletionBlock)completion {

    return [ASConnection connectionWithRequest:request
                                        toFile:nil
                         downloadProgressBlock:downloadProgress
                           uploadProgressBlock:uploadProgress
                               completionBlock:completion];
}

/////////////////////////////////////////////////////////////////////////////////////
+ (id)connectionWithRequest:(NSURLRequest *)request
                     toFile:(NSURL *)toFileURL
      downloadProgressBlock:(ASConnectionProgressBlock)downloadProgress
        uploadProgressBlock:(ASConnectionProgressBlock)uploadProgress
            completionBlock:(ASConnectionCompletionBlock)completion {
    
    return [[self alloc] initWithRequest:request
                                  toFile:toFileURL
                   downloadProgressBlock:downloadProgress
                     uploadProgressBlock:uploadProgress
                         completionBlock:completion];
}

/////////////////////////////////////////////////////////////////////////////////////
+ (id)connectionWithURL:(NSURL *)downloadURL
          progressBlock:(ASConnectionProgressBlock)progress
        completionBlock:(ASConnectionCompletionBlock)completion {

    return [ASConnection connectionWithURL:downloadURL
                                    toFile:nil
                             progressBlock:progress
                           completionBlock:completion];
}

/////////////////////////////////////////////////////////////////////////////////////
+ (id)connectionWithURL:(NSURL *)downloadURL
                 toFile:(NSURL *)toFileURL
          progressBlock:(ASConnectionProgressBlock)progress
        completionBlock:(ASConnectionCompletionBlock)completion {

    return [[self alloc] initWithURL:downloadURL
                              toFile:toFileURL
                       progressBlock:progress
                     completionBlock:completion];    
}

/////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURL:(NSURL *)requestURL
           toFile:(NSURL *)toFileURL
    progressBlock:(ASConnectionProgressBlock)progress
  completionBlock:(ASConnectionCompletionBlock)completion {
    
    return [self initWithRequest:[NSURLRequest requestWithURL:requestURL]
                          toFile:toFileURL
           downloadProgressBlock:progress
             uploadProgressBlock:nil
                 completionBlock:completion];
}

/////////////////////////////////////////////////////////////////////////////////////
- (id)initWithRequest:(NSURLRequest *)request
               toFile:(NSURL *)toFileURL
downloadProgressBlock:(ASConnectionProgressBlock)downloadProgress
  uploadProgressBlock:(ASConnectionProgressBlock)uploadProgress
      completionBlock:(ASConnectionCompletionBlock)completion {

    if ((self = [super init])) {
        
        self.downloadFileURL = toFileURL;
        self.urlRequest = request;
        self.downloadProgressBlock = downloadProgress;
        self.uploadProgressBlock = uploadProgress;
        self.completionBlock = completion;
        self.url = [request URL];
        self.connectionError = nil;
        progressThreshold = 1.0 / 360.0;
    }
    
    return self;
}

#pragma mark -
#pragma mark 

/////////////////////////////////////////////////////////////////////////////////////
- (void)start {
    
    [self startWithBlocking:NO];
}

/////////////////////////////////////////////////////////////////////////////////////
- (void)startWithBlocking:(BOOL)isBlocking {    
    
    self.connection = [NSURLConnection connectionWithRequest:self.urlRequest delegate:self];
    
    while(isBlocking && self.connection) {
        
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

/////////////////////////////////////////////////////////////////////////////////////
- (void)stop {

    [self.connection cancel];
    self.connection = nil;
    self.connectionError = nil;
    self.downloadData = nil;
    self.downloadFileURL = nil;
    self.downloadStream = nil;
    self.responseHeaderFields = nil;
    self.contentLength = 0;
    self.downloadProgressBlock = nil;
    self.uploadProgressBlock = nil;
    self.completionBlock = nil;
}

/////////////////////////////////////////////////////////////////////////////////////
- (float)downloadPercentComplete {

    if (self.contentLength <= 0) {
        return 0;
    }
    
    float complete = 0.0;
    
    if ( nil != self.downloadFileURL ) {
        
        unsigned long long currentFileOffset = [self.downloadStream offsetInFile];
        complete = ((currentFileOffset * 1.0f) / self.contentLength) ;
    } else {
        
        complete = (([self.downloadData length] * 1.0f) / self.contentLength);
    }
    
    return complete;
}

#pragma mark 
#pragma mark NSURLConnectionDelegate

/////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)urlConnection didReceiveResponse:(NSURLResponse *)response {

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {

        //NSLog(@"Connection Response URL: %@", [urlConnection currentRequest].URL);
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = [httpResponse statusCode];
        NSLog(@"Connection Response Status: %ld", statusCode);
        
        BOOL successStatus = NO;
        //if ((statusCode == 200) || (statusCode == 201) || (statusCode == 204)) {
        if ( 200 <= statusCode && statusCode < 300 ) {
            successStatus = YES;
        }
        
        self.responseHeaderFields = [httpResponse allHeaderFields];
        NSLog(@"Connection Response Headers: %@", self.responseHeaderFields);
        
        NSString *contentLen = [self.responseHeaderFields valueForKey:@"Content-Length"];
        if (contentLen) {
            self.contentLength = [contentLen integerValue];
        } else {
            // Only use the expected file size if the response was a 'success'
            if ( successStatus ) {
                self.contentLength = self.fileSize;
            }
        }
        NSLog(@"Connection Response Length: %ld", self.contentLength);
        
        // Only create the stream if the response was a 'success'
        if ( YES == successStatus && nil != self.downloadFileURL ) {
            NSError* nserror;
            [[NSFileManager defaultManager] createFileAtPath:[self.downloadFileURL path] contents:nil attributes:nil];
            self.downloadStream = [NSFileHandle fileHandleForWritingToURL:self.downloadFileURL error:&nserror];
        } else {
            self.downloadData = [NSMutableData dataWithCapacity:self.contentLength];
        }
        
        // If we were unsuccessful, record it, and propergate it now if we are not expending any more data.
        if ( NO == successStatus ) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[httpResponse allHeaderFields]];
            if (![userInfo objectForKey:NSLocalizedDescriptionKey]) {
                [userInfo setObject:[NSHTTPURLResponse localizedStringForStatusCode:statusCode] forKey:NSLocalizedDescriptionKey];
            }
            self.connectionError = [[NSError alloc] initWithDomain:@"ASConnection"
                                                              code:statusCode
                                                          userInfo:userInfo ];
            if ( 0 == self.contentLength ) {
                if (self.completionBlock){
                    self.completionBlock(self, self.connectionError);
                }
                self.connection = nil;
            }
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    if ( nil != self.downloadStream ) {
        [self.downloadStream writeData:data];
    } else {
        [self.downloadData appendData:data];
    }
    
    float pctComplete = [self downloadPercentComplete];
    if ((pctComplete - self.previousMilestone) >= self.progressThreshold) {
        
        self.previousMilestone = pctComplete;
        if (self.downloadProgressBlock) {
            self.downloadProgressBlock(self);   
        }
    }
}

///TODO:Code upload Progress
/////////////////////////////////////////////////////////////////////////////////////
-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{

    self.uploadPercentComplete = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    if (self.uploadProgressBlock) {
        self.uploadProgressBlock(self);   
    }
}

/////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    NSLog(@"Connection failed: %@", error);
    
    if ( self.downloadStream ) {
        
        [self.downloadStream closeFile];
        if ([[NSFileManager defaultManager] removeItemAtPath:[self.downloadFileURL path] error:nil]  == YES) {
            NSLog (@"Remove successful");
        } else {
            NSLog (@"Remove failed");    
        }    
    }
    
    if (self.completionBlock) {
        self.completionBlock(self, error);    
    }
    self.connection = nil;
}

/////////////////////////////////////////////////////////////////////////////////////
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    if ( self.downloadStream ) {
        [self.downloadStream closeFile];
    }
    
    if (self.connection) {
        if (self.completionBlock) {
            self.completionBlock(self, self.connectionError);
        }            
        self.connection = nil;
    }
}

/////////////////////////////////////////////////////////////////////////////////////
-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    
    NSURLProtectionSpace * protectionSpace = [challenge protectionSpace];
    NSURLCredential* credentail = [NSURLCredential credentialForTrust:[protectionSpace serverTrust]];
    [[challenge sender] useCredential:credentail forAuthenticationChallenge:challenge];
}


/*
 if ([[[challenge protectionSpace] authenticationMethod] isEqualToString:@"NSURLAuthenticationMethodServerTrust"]) {
 [[challenge sender] performDefaultHandlingForAuthenticationChallenge:challenge];
 }
 else {
 if ([challenge previousFailureCount] <= maxRetryCount ) {
 NSURLCredential *newCredential =
 [NSURLCredential
 credentialWithUser: userName
 password:password
 persistence:NSURLCredentialPersistenceForSession];
 
 [[challenge sender]
 useCredential:newCredential
 forAuthenticationChallenge:challenge];
 
 }
 else
 {
 NSLog(@"Failure count %d",[challenge previousFailureCount]);
 }
 }
 
 */
/*
// to deal with self-signed certificates
- (BOOL)connection:(NSURLConnection *)connection
canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	return [protectionSpace.authenticationMethod
			isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge.protectionSpace.authenticationMethod
		 isEqualToString:NSURLAuthenticationMethodServerTrust])
	{
		// we only trust our own domain
        NSLog(@"Server=%@",[self.url host]);
		if ([challenge.protectionSpace.host isEqualToString:@"www.cocoanetics.com"])
		{
			NSURLCredential *credential =
            [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
			[challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
		}
	}
    
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
 */
@end