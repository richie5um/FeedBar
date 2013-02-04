/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
***/
//
//  ASMultipartPOSTRequest.h
//  MultipartHTTPPost
//
//  Created by Matt Drance on 9/21/10.
//  Copyright 2010 Bookhouse Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASMultipartPOSTRequest;

typedef void (^ASBodyCompletionBlock)(ASMultipartPOSTRequest *);
typedef void (^ASBodyErrorBlock)(ASMultipartPOSTRequest *, NSError *);
typedef void (^ASBodyProgressBlock)(ASMultipartPOSTRequest *connection);

@interface ASMultipartPOSTRequest : NSMutableURLRequest <NSStreamDelegate> {}

-(void)setUploadFile:(NSString *)path
         contentType:(NSString *)type
           nameParam:(NSString *)nameParam
            filename:(NSString *)fileName;

-(void)prepareForUploadWithCompletionBlock:(ASBodyCompletionBlock)completion
                             progressBlock:(ASBodyProgressBlock)progress
                                errorBlock:(ASBodyErrorBlock)error;

-(NSInteger)appendBodySection:(NSString*)string withType:(NSString*)type;
-(void)stop;

@property (nonatomic, copy) NSString *HTTPBoundary;
@property (nonatomic, retain) NSDictionary *formParameters;
@property (nonatomic, retain) NSNumber* fileSize;
@property (nonatomic, assign) float progressThreshold;
@property (nonatomic, assign, readonly) float percentComplete;



@end