//
//  TweetData.m
//  TestApp
//
//  Created by Pritesh Lad on 13/05/16.
//  Copyright © 2016 Test. All rights reserved.
//

#import "TweetData.h"

@implementation TweetData

- (id)initWithDictionary:(NSDictionary*)tweetDict
{
    self = [super init];
    
    if (self && tweetDict != nil )
    {
        self.tweetText = [tweetDict valueForKey:@"text"];

        
        NSDictionary *user = [tweetDict valueForKey:@"user"];
        
        if (user != nil) {
            self.profileImageUrl = [user valueForKey:@"profile_image_url"];
            self.userName = [user valueForKey:@"name"];
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
            
            NSDate *date = [df dateFromString:[user valueForKey:@"created_at"]];
            [df setDateFormat:@"HH:mm MMM dd, yyyy"];
            self.dateString = [df stringFromDate:date];

        }
    }
    
    return self;
}
@end
