//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Copyright (c) 2013 Glenn Chiu
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "GCJSONRequestOperation.h"

#if ! __has_feature(objc_arc)
#   error GCNetworkRequest is ARC only. Use -fobjc-arc as compiler flag for this library
#endif

@implementation GCJSONRequestOperation
{
    NSError *_JSONError;
}

+ (instancetype)JSONRequest:(GCNetworkRequest *)networkRequest
              callBackQueue:(dispatch_queue_t)queue
          completionHandler:(void(^)(id JSON, NSHTTPURLResponse *response))completionBlock
               errorHandler:(void(^)(id JSON, NSHTTPURLResponse *response, NSError *error))errorBlock
           challengeHandler:(void(^)(NSURLConnection * connection, NSURLAuthenticationChallenge * challenge))challengeBlock;
{
    __block GCJSONRequestOperation *operation = nil;
    
    operation = [[GCJSONRequestOperation alloc] initWithHTTPRequest:networkRequest
                                                      callBackQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul)
                                                  completionHandler:^(NSData *data, NSHTTPURLResponse *response) {
                                                      
                                                      if (completionBlock)
                                                      {
                                                          id JSONObject = [operation processJSON:data];
                                                          
                                                          dispatch_async(gc_dispatch_queue(queue), ^{completionBlock(JSONObject, response);});
                                                      }
                                                      
                                                      operation = nil;
                                                      
                                                  } errorHandler:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                                                      
                                                      if (errorBlock)
                                                      {
                                                          id JSONObject = [operation processJSON:data];
                                                          
                                                          dispatch_async(gc_dispatch_queue(queue), ^{errorBlock(JSONObject, response, [operation error]);});
                                                      }
                                                      
                                                      operation = nil;
                                                  } challengeHandler:challengeBlock
                 ];
    return operation;
}

- (id)processJSON:(NSData *)data
{
    id JSONObject = nil;
    
    if (data)
    {
        NSError *error = nil;
        JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if (!JSONObject) [self setError:error];
    }
    return JSONObject;
}

- (NSError *)error
{
    return (self->_JSONError) ?: [super error];
}

- (void)setError:(NSError *)error
{
    self->_JSONError = error;
}

@end
