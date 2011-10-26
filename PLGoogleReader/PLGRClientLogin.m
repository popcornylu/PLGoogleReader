//
//  PLGRClientLogin.m
//  PLGoogleReader
//
//  Created by Popcorny on 10/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PLGRClientLogin.h"

@interface PLGRClientLogin()
@property (nonatomic, retain) NSURLConnection* connection;
@property (nonatomic, retain) NSMutableData* data;
@end


@implementation PLGRClientLogin

@synthesize email = _email;
@synthesize connection = _connection;
@synthesize data = _data;
@synthesize auth = _auth;
@synthesize completeBlock = _completeBlock;

- (void)dealloc
{
    self.email = nil;
    self.connection = nil;
    self.data = nil;
    self.auth = nil;
    self.completeBlock = nil;
    
    [super dealloc];
}

#pragma mark NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection 
didReceiveResponse:(NSURLResponse *)response
{
    self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection 
    didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString* result = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    NSError* error = nil;    
    
    NSScanner* scanner = [[NSScanner alloc] initWithString:result];
    NSString* auth = nil;
    if([scanner scanUpToString:@"Auth=" intoString:nil])
    {
        if([scanner scanString:@"Auth=" intoString:nil])
        {
            [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&auth];
        }
    }       

    // notify the result;

    if(auth)
    {
        self.auth = auth;
    }
    else    
    {
        error = [NSError errorWithDomain:@"PLGoogleReaderDomain" 
                                    code:0 
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:result, NSLocalizedDescriptionKey, nil]];
    }
    self.completeBlock(error);
    self.completeBlock = nil;    
    
    
    [scanner release];
    [result release];    
    self.connection = nil;
    self.data = nil;    
}


- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.data = nil;    
    
    self.completeBlock(error);
    self.completeBlock = nil;
}

#pragma mark Public
- (void)loginWithEmail:(NSString*)email
              password:(NSString*)password
              complete:(void(^)(NSError*))complete
{
    NSString* urlString = [NSString stringWithFormat:@"https://www.google.com/accounts/ClientLogin?Email=%@&Passwd=%@&source=SmartQ&service=reader", 
                           email, 
                           password];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [_connection start];
    self.completeBlock = complete;        
}

- (void)logout
{
    self.auth = nil;
}

- (BOOL)authorizeRequest:(NSMutableURLRequest *)request
{
    if(self.auth)
    {
        [request addValue:[NSString stringWithFormat:@"GoogleLogin auth=%@", self.auth] forHTTPHeaderField:@"Authorization"];
        [request addValue:@"3.0" forHTTPHeaderField:@"GData-Version"];        
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
