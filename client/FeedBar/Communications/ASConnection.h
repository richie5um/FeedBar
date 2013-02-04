/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
***/
//
//  ASConnection.h
//  SimpleDownload
//
//  Created by Matt Drance on 3/1/10.
//  Copyright 2010 Bookhouse Software, LLC. All rights reserved.
//

#import <AppKit/AppKit.h>

#import "ASFormEncodedPOSTRequest.h"
#import "ASMultipartPOSTRequest.h"

#import "NSData+DataConversion.h"

@class ASConnection;

typedef void (^ASConnectionProgressBlock)(ASConnection *connection);
typedef void (^ASConnectionCompletionBlock)(ASConnection *connection, NSError *error);

@interface ASConnection : NSObject {}

@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, copy, readonly) NSURLRequest *urlRequest;
@property (nonatomic, copy, readonly) NSURL *downloadFileURL;
@property (nonatomic, copy, readonly) NSURL *uploadFileURL;
@property (nonatomic, retain, readonly) NSFileHandle* downloadStream;
@property (nonatomic, retain, readonly) NSFileHandle* uploadStream;
@property (nonatomic, assign) NSInteger fileSize;
@property (nonatomic, assign, readonly) NSInteger contentLength;
@property (nonatomic, retain, readonly) NSMutableData *downloadData;
@property (nonatomic, retain, readonly) NSDictionary *responseHeaderFields;
@property (nonatomic, assign, readonly) float downloadPercentComplete;
@property (nonatomic, assign, readonly) float uploadPercentComplete;
@property (nonatomic, assign) float progressThreshold;
@property (nonatomic, retain) NSError* connectionError;


+ (id)connectionWithURL:(NSURL *)requestURL
          progressBlock:(ASConnectionProgressBlock)progress
        completionBlock:(ASConnectionCompletionBlock)completion;

+ (id)connectionWithURL:(NSURL *)requestURL
                 toFile:(NSURL *)toFileURL
          progressBlock:(ASConnectionProgressBlock)progress
        completionBlock:(ASConnectionCompletionBlock)completion;

+ (id)connectionWithRequest:(NSURLRequest *)request
      downloadProgressBlock:(ASConnectionProgressBlock)downloadProgress
        uploadProgressBlock:(ASConnectionProgressBlock)uploadProgress
            completionBlock:(ASConnectionCompletionBlock)completion;

+ (id)connectionWithRequest:(NSURLRequest *)request
                     toFile:(NSURL *)toFileURL
              downloadProgressBlock:(ASConnectionProgressBlock)downloadProgress
        uploadProgressBlock:(ASConnectionProgressBlock)uploadProgress
            completionBlock:(ASConnectionCompletionBlock)completion;

- (id)initWithURL:(NSURL *)requestURL
           toFile:(NSURL *)toFileURL
    progressBlock:(ASConnectionProgressBlock)progress
  completionBlock:(ASConnectionCompletionBlock)completion;

- (id)initWithRequest:(NSURLRequest *)request
               toFile:(NSURL *)toFileURL
downloadProgressBlock:(ASConnectionProgressBlock)downloadProgress
  uploadProgressBlock:(ASConnectionProgressBlock)uploadProgress
      completionBlock:(ASConnectionCompletionBlock)completion;

- (void)start;
- (void)startWithBlocking:(BOOL)isBlocking;
- (void)stop;

@end