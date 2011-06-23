//
//  PLGRRequest.m
//  PLGoogleReader
//
//  Created by popcornylu on 6/11/11.
//  Copyright 2011 SmartQ. All rights reserved.
//

#import "PLGRRequest.h"
#import "PLGoogleReader.h"

////////////////////////////////////////////////////////////////////////////////
// Private definition
@interface PLGRRequest()
@end

////////////////////////////////////////////////////////////////////////////////
@implementation PLGRRequest

@synthesize delegate = _delegate;

@synthesize googleReader = _googleReader;
@synthesize url = _url;
@synthesize params = _params;
@synthesize httpMethod = _httpMethod;


#pragma mark NSObject
- (void)dealloc
{
    // clean the params
    [_googleReader release];    
    [_url release];
    [_params release];
    [_httpMethod release];
    
    // clean the data
    if(_urlConncetion)
    {    
        [_urlConncetion cancel];        
    }    
    
    if(_data)
    {
        [_data release];
    }
    
    //
    [super dealloc];    
}

#pragma mark NSURLConnection Delegate (Async)
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[_data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {    
	[_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{	    
    [_delegate request:self didLoad:_data];
    
    
    // release the connection
    [_data release];
    _data = nil;
    [_urlConncetion release];
    _urlConncetion = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [_delegate request:self didFailWithError:error];
    
    
    // release the connection
    [_data release];
    _data = nil;
    [_urlConncetion release];
    _urlConncetion = nil;    
}

#pragma mark Public
-(void)connect
{
    if([self isLoading])
    {        
        return;
    }
    
    if(!_url || !_googleReader)
    {
        return;        
    }
    
    // Add the params to the url 
    if(_params)
    {        
        NSString* baseUrl     = [_url absoluteString];
        NSString* queryPrefix = [_url query] ? @"&" : @"?";
        
        NSMutableArray* pairs = [NSMutableArray array];
        for (NSString* key in [_params keyEnumerator]) {           
            NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                          NULL, /* allocator */
                                                                                          (CFStringRef)[_params objectForKey:key],
                                                                                          NULL, /* charactersToLeaveUnescaped */
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8);
            
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
            [escaped_value release];
        }
        NSString* query = [pairs componentsJoinedByString:@"&"];
        
        self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", baseUrl, queryPrefix, query]];
    }    
    
    // create the url request
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:_url];    
    
    //
    if(_httpMethod)
    {
        [urlRequest setHTTPMethod:_httpMethod];
    }    
    
    // authorize the request
    if(![_googleReader authorizeRequest:urlRequest])
    {
        return;
    }    
    
    // prepare data and connection
    _data = [[NSMutableData alloc] initWithCapacity:0]; 
    _urlConncetion = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];    
}

-(void)cancel
{
    [_urlConncetion cancel];
}

-(BOOL)isLoading
{
    return _urlConncetion != nil;
}

@end
