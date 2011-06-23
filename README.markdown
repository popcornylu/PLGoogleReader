# PLGoogleReader

## Introduction
PLGoogleReader is an iOS library of [Google Reader](http://www.google.reader/).
Since now, google reader has not announced offical API. The implementation is based on the reverse-engineering result shared by [pyrfeed](http://code.google.com/p/pyrfeed/wiki/GoogleReaderAPI).
For login, PLGoogleReader use [gtm-auth](http://code.google.com/p/gtm-oauth/) to implement the oauth authetication.	

## Add PLGoogleReader to your project

**Step1. Add frameworks used by PLGoogleReader**

1. Open Xcode
2. Select the project file
3. Select a target
4. Select **Build Phases** tab
5. Open **Link Binary with Libraries**
6. Add **SystemConfiguration.framework** and **Security.framework**

**Step2. Add all sources for libraries used by PLGoogleReader**

Copy all files in */Enternals* to your project

**Step3. Copy the PLGoogleReader source**

Copy all the files in the */PLGoogleReader* to your project.

## How to use.

Actually, you can easilty look into the example files to know how to use this library. Here, I briefly
describe the usage of PLGoogleReader.

1. `GoogleReader.h` - The only header file you need to include.
2. `PLGoogleReader` - The main class of PLGoogleReader. We use it to signin, get the subscription object, and send a GoogleReader request.
3. `PLGRRequest` - The request object is inspried by the **facebook-ios-sdk**. All the PLGoogleReader request would return a request object. we can cancel the request if necessary.
4. `PLSubscription` - This is a high level class to perform multiple request to Google Reader and build up the subscription list.
5. `PLSubscriptionItem` - Represent an entry of the subscripition list. An entry can be a tag, label, or feed.

### Get a PLGoogleReader object
Simplily call `+[PLGoogleReader defaultGoogleReader]` to get the google reader instance.

	PLGoogleReader* googleReader = [PLGoogleReader defaultGoogleReader];

### Sign in

For signin, we use the gtm-oauth to implement the oauth. In this library, there has been an easy-to-use view controller `GTMOAuthViewControllerTouch` to provide the signin web ui.
The only thing PLGoogleReader does is just return the `GTMOAuthViewControllerTouch` view controller back to caller.

	UIViewController* viewController = [googleReader viewControllerForSignIn:self];    
    [self.navigationController pushViewController:viewController animated:YES];        
    
And in your view controller class, also remember to implement the `PLGoogleReaderSignInDelegate` protocol to receive the signin result.

### Subscription list	
The subscription list is implemented by the class `PLGRSubscription`. It is a placeholder to preserve the result of the following google reader API.

- <http://www.google.com/reader/api/0/subscription/list> - A list of all the subscribed feed.
- <http://www.google.com/reader/api/0/tag/list> - A list of all the user defined or system defined tags.
- <http://www.google.com/reader/api/0/preference/stream/list> - The sorting for tags.
- <http://www.google.com/reader/api/0/unread-count> - The unread count for tags.

To get a instance, just

	PLGRSubscription* subscription = [googleReader subscription];
	
After getting this instance, you may need to load the subscription

	[subscription reload:self];
	
In this piece of code, it would reload the subscription list, and set the delegate to `self`. Once complete, you can get the subscription list by

	NSArray* subscriptionList = [subscription subscriptionList];
	for(PLGRSubscriptionItem* item in subscriptionList)
	{
		NSLog(@"the subscribed item is %@", item.streamid];
	}
	
or get the tag list by

	NSArray* tagList = [subscription tagList];	
	
or get the sorted subscription list of root directory.

	NSArray* sortedList = [subscription sortedListForTag:nil];
	
or get the sorted subscription list of specified tag

	NSArray* sortedList = [subscription sortedListForTag:@"/user/-/label/mylabel"];

Usually, we may have a tree UI to show the subscription list (just like the bottom-left list in the offical google reader website).
All you need to do is interate the items in root directory and put the `item.streamid` as argument of `-[PLGRSubscription sortedListForTag:]`.

### Get the feed data
Get the stream data

	PLGRSubscriptionItem* item = ...;
	[googleReader requestWithStreamContents:item.streamid
             	                 withParams:nil
						       withDelegate:self];	// delegate of type PLGRRequestDelegate

On complete, parse the JSON

	- (void)request:(PLGRRequest*)request didLoad:(NSData*)data
	{        			
		NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];        
		id resultData = [result JSONValue];
		// parse the json daa.
	}
	
### Mark as read or mark all as read.
We have not implemented a high level API for this requirement. But you can use `-[PLGoogleReader requestWithAPIPath:withParams:withHttpMethod:withDelegate]` to archive it though.

## External Libraries

- [json-framework](http://code.google.com/p/json-framework/) - json parser
- [gtm-oauth](http://code.google.com/p/gtm-oauth/) - use it for oauth implemention
- [gtm](http://code.google.com/p/google-toolbox-for-mac/) - use the NSString+HTML addition.

## Reference
The project reference the following articles. 

- <http://code.google.com/p/pyrfeed/wiki/GoogleReaderAPI>
- <http://blog.martindoms.com/2009/08/15/using-the-google-reader-api-part-1/>
- <http://blog.martindoms.com/2009/10/16/using-the-google-reader-api-part-2/>
- <http://blog.martindoms.com/2010/01/20/using-the-google-reader-api-part-3/>

## License
PLGoogleReader is under LGPL license. 

## Contact me
If you encounter any problem, feel free to mail me. <popcorny@gmail.com>
