/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
***/
//
//  ASMultipartPOSTRequest.m
//  MultipartHTTPPost
//
//  Created by Matt Drance on 9/21/10.
//  Copyright 2010 Bookhouse Software, LLC. All rights reserved.
//

#import "ASMultipartPOSTRequest.h"

/////////////////////////////////////////////////////////////////////////////////////
@interface ASUploadFileInfo : NSObject {}

@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *nameParam;
@property (nonatomic, copy) NSString *fileName;

@end

/////////////////////////////////////////////////////////////////////////////////////
@interface ASMultipartPOSTRequest ()

- (NSString *)preparedBoundary;

- (void)startRequestBody;
- (NSInteger)appendBodyString:(NSString *)string;
- (void)finishRequestBody;

- (void)finishMediaInputStream;
- (void)handleStreamCompletion;
- (void)handleStreamError:(NSError *)error;

@property (nonatomic, copy) NSString *pathToBodyFile;
@property (nonatomic, retain) NSOutputStream *bodyFileOutputStream;

@property (nonatomic, retain) ASUploadFileInfo *fileToUpload;
@property (nonatomic, retain) NSInputStream *uploadFileInputStream;

@property (nonatomic, copy) ASBodyCompletionBlock prepCompletionBlock;
@property (nonatomic, copy) ASBodyProgressBlock prepProgressBlock;
@property (nonatomic, copy) ASBodyErrorBlock prepErrorBlock;

@property (nonatomic, assign, getter=isStarted) BOOL started;
@property (nonatomic, assign, getter=isFirstBoundaryWritten) BOOL firstBoundaryWritten;

@property (nonatomic, assign) long long fileBytesUploaded;
@property (nonatomic, assign) float previousMilestone;

@property (nonatomic, assign) BOOL isFinished;

@end

/////////////////////////////////////////////////////////////////////////////////////
@implementation ASMultipartPOSTRequest

@synthesize HTTPBoundary;

@synthesize formParameters;
@synthesize fileToUpload;
@synthesize uploadFileInputStream;

@synthesize pathToBodyFile;
@synthesize bodyFileOutputStream;

@synthesize prepCompletionBlock;
@synthesize prepProgressBlock;
@synthesize prepErrorBlock;

@synthesize started;
@synthesize firstBoundaryWritten;

@synthesize fileSize;
@synthesize fileBytesUploaded;
@synthesize progressThreshold;
@synthesize previousMilestone;
@synthesize isFinished;

/////////////////////////////////////////////////////////////////////////////////////
- (void)setUploadFile:(NSString *)path
          contentType:(NSString *)type
            nameParam:(NSString *)nameParam
             filename:(NSString *)fileName {
    
    ASUploadFileInfo *info = [[ASUploadFileInfo alloc] init];
    
    info.localPath = path;
    info.nameParam = nameParam;
    info.contentType = type;
    info.fileName = fileName;
    
    self.fileToUpload = info;
    
    self.progressThreshold = 1.0 / 360.0;
}

#pragma mark -
#pragma mark Request body preparation

/////////////////////////////////////////////////////////////////////////////////////
- (void)startRequestBody {

    if (!self.started) {

        self.started = YES;
        
        [self setHTTPMethod:@"POST"];
        NSString *format = @"multipart/form-data; boundary=%@";
        NSString *contentType = [NSString stringWithFormat:format,
                                 self.HTTPBoundary];
        [self setValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        NSString *extension = @"multipartbody";
        NSString *bodyFileName = [(__bridge NSString *)uuidStr stringByAppendingPathExtension:extension];
        CFRelease(uuidStr);
        CFRelease(uuid);        

        self.pathToBodyFile = [NSTemporaryDirectory()
                               stringByAppendingPathComponent:bodyFileName];
        NSString *bodyPath = self.pathToBodyFile;
        self.bodyFileOutputStream = [NSOutputStream
                                     outputStreamToFileAtPath:bodyPath
                                                       append:YES];
        
        [self.bodyFileOutputStream open];
    }
}

/////////////////////////////////////////////////////////////////////////////////////
- (void)finishRequestBody {

    [self appendBodyString:[NSString stringWithFormat:@"\r\n--%@--\r\n", self.HTTPBoundary]];
    [self.bodyFileOutputStream close];
    self.bodyFileOutputStream = nil;
    
    NSError *fileReadError = nil;
    NSDictionary *fileAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:self.pathToBodyFile error:&fileReadError];
    NSAssert1((fileAttrs != nil), @"Couldn't read post body file;", fileReadError);
    NSNumber *contentLength = [fileAttrs objectForKey:NSFileSize];
    NSLog(@"Body length %@", [contentLength stringValue]);
    [self setValue:[contentLength stringValue] forHTTPHeaderField:@"Content-Length"];
    
    NSLog(@"Setting bodyStream from %@", self.pathToBodyFile);
    NSInputStream *bodyStream = [[NSInputStream alloc] initWithFileAtPath:self.pathToBodyFile];
    [self setHTTPBodyStream:bodyStream];
}

/////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)appendBodySection:(NSString*)string withType:(NSString*)type {
    
    NSMutableString *params = [NSMutableString string];
    [params appendString:[self preparedBoundary]];
    
    [params appendFormat:@"Content-type: %@\r\n", type];
    [params appendString:@"\r\n"];
    [params appendString:string];
    
    return [self appendBodyString:string];
}

/////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)appendBodyString:(NSString *)string {

    [self startRequestBody];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self.bodyFileOutputStream write:[data bytes] maxLength:[data length]];
}

/////////////////////////////////////////////////////////////////////////////////////
- (NSString *)preparedBoundary {

    NSString *boundaryFormat =  self.firstBoundaryWritten ? @"\r\n--%@\r\n" : @"--%@\r\n";
    self.firstBoundaryWritten = YES;
    return [NSString stringWithFormat:boundaryFormat, self.HTTPBoundary];
}

/////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForUploadWithCompletionBlock:(ASBodyCompletionBlock)completion
                              progressBlock:(ASBodyProgressBlock)progress
                                 errorBlock:(ASBodyErrorBlock)error {

    self.prepCompletionBlock = completion;
    self.prepProgressBlock = progress;
    self.prepErrorBlock = error;
    
    [self startRequestBody];

    NSMutableString *params = [NSMutableString string];
    NSArray *keys = [self.formParameters allKeys];
    for (NSString *key in keys) {

        @autoreleasepool {
            
            [params appendString:[self preparedBoundary]];
            NSString *fmt = @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n";
            [params appendFormat:fmt, key];
            [params appendFormat:@"%@", [self.formParameters objectForKey:key]];
        }
    }

    if ([params length]) {

        if ([self appendBodyString:params] == -1) {

            self.prepErrorBlock(self, [self.bodyFileOutputStream streamError]);
            return;
        }        
    }
   
    if (self.fileToUpload) {

        NSMutableString *str = [[NSMutableString alloc] init];
        [str appendString:[self preparedBoundary]];
        
        // Set the Form-Data information
        [str appendString:@"Content-Disposition: form-data; "];
        if ( nil != self.fileToUpload.nameParam ) {
            [str appendFormat:@"name=\"%@\"; ", self.fileToUpload.nameParam];
        }
        if ( nil != self.fileToUpload.fileName ) {
            [str appendFormat:@"filename=\"%@\"", self.fileToUpload.fileName];
        }
        [str appendString:@"\r\n"];
        
        // Set the Content-Type information
        if ( nil != self.fileToUpload.contentType ) {
            [str appendFormat:@"Content-Type: %@\r\n", self.fileToUpload.contentType];
        }
        [str appendString:@"\r\n"];
        
        // Finish the Form-Data section and add to the body.
        [self appendBodyString:str];         
        
        NSLog(@"Preparing to stream %@", self.fileToUpload.localPath);
        NSString *path = self.fileToUpload.localPath;
        
        // Get file size information
        NSDictionary* fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        self.fileSize = [fileDict objectForKey:NSFileSize];
        self.fileBytesUploaded = 0;        
        
        // Initiate the file stream
        NSInputStream *mediaInputStream = [[NSInputStream alloc] initWithFileAtPath:path];
        self.uploadFileInputStream = mediaInputStream;
        
        [self.uploadFileInputStream setDelegate:self];
        //        [self.uploadFileInputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        //        [self.uploadFileInputStream open];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSRunLoop *loop = [NSRunLoop currentRunLoop];
            [self.uploadFileInputStream scheduleInRunLoop:loop forMode:NSDefaultRunLoopMode];
            [self.uploadFileInputStream open];
            self.isFinished = NO;
            while(!self.isFinished) {
                [loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            NSLog(@"Done!");
        });
    } else {

        [self handleStreamCompletion];
    }
}

#pragma mark -
#pragma mark Runloop handler for copying the upload file

/////////////////////////////////////////////////////////////////////////////////////
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {

    uint8_t buf[1024*100];
    NSUInteger len = 0;
    switch(eventCode) {

        case NSStreamEventOpenCompleted:
            NSLog(@"Media file opened");
            break;

        case NSStreamEventHasBytesAvailable:
            len = [self.uploadFileInputStream read:buf maxLength:1024];
            if (len) {
                [self.bodyFileOutputStream write:buf maxLength:len];
                self.fileBytesUploaded +=len;
                float pctComplete = [self percentComplete];
                if ((pctComplete - self.previousMilestone) >= self.progressThreshold) {
                    self.previousMilestone = pctComplete;
                    if (self.prepProgressBlock){
                        self.prepProgressBlock(self);
                    }
                }
            } else {
                NSLog(@"Buffer finished; wrote to %@", self.pathToBodyFile);
                [self handleStreamCompletion];
            }
            break;

        case NSStreamEventErrorOccurred:
            NSLog(@"ERROR piping image to body file %@", [stream streamError]);
            self.prepErrorBlock(self, [stream streamError]);
            break;

        default:
            NSLog(@"Unhandled stream event (%d)", eventCode);
            break;
    }
}

/////////////////////////////////////////////////////////////////////////////////////
-(void)stop{
    
    [self finishMediaInputStream];
}

/////////////////////////////////////////////////////////////////////////////////////
- (void)handleStreamCompletion {

    [self finishMediaInputStream];
    [self finishRequestBody];
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        self.prepCompletionBlock(self);
    });
}

/////////////////////////////////////////////////////////////////////////////////////
- (void)finishMediaInputStream {

    self.isFinished = YES;
    [self.uploadFileInputStream close];
    [self.uploadFileInputStream removeFromRunLoop:[NSRunLoop currentRunLoop] 
                                          forMode:NSDefaultRunLoopMode];
    self.uploadFileInputStream = nil;
}

/////////////////////////////////////////////////////////////////////////////////////
- (void)handleStreamError:(NSError *)error {

    [self finishMediaInputStream];
    self.prepErrorBlock(self, error);
}

#pragma mark -
#pragma mark Accessors

/////////////////////////////////////////////////////////////////////////////////////
- (NSString *)HTTPBoundary {

    NSAssert2(([HTTPBoundary length] > 0), @"-[%@ %@] Invalid or nil HTTPBoundary", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return HTTPBoundary;
}

/////////////////////////////////////////////////////////////////////////////////////
- (void)setHTTPBoundary:(NSString *)boundary {

    if (HTTPBoundary == nil) {

        HTTPBoundary = [boundary copy];
    } else {

        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"HTTPBoundary cannot be changed once set (old='%@' new='%@')", HTTPBoundary, boundary]
                                     userInfo:nil];
    }
}

/////////////////////////////////////////////////////////////////////////////////////
- (float)percentComplete {
    
    long long totalFileSize = [self.fileSize longLongValue];
    
    if (totalFileSize <= 0){ 
        return 0;
    }
    
    float complete = ((fileBytesUploaded*1.0f)/totalFileSize);
    return complete;
}

@end

/////////////////////////////////////////////////////////////////////////////////////
@implementation ASUploadFileInfo

@synthesize localPath, contentType, nameParam, fileName;

/////////////////////////////////////////////////////////////////////////////////////
- (NSString *)fileName {

    if (fileName == nil) {

        return [localPath lastPathComponent];
    }
    return fileName;
}

/* RichS: Removed from ARC
- (void)dealloc {
    [localPath release], localPath = nil;
    [contentType release], contentType = nil;
    [nameParam release], nameParam = nil;
    [fileName release], fileName = nil;
    
    [super dealloc];
}
*/

@end
