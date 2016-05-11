//
//  MessageData.m
//  TestApp
//
//  Created by Pritesh Lad on 11/05/16.
//  Copyright © 2016 Test. All rights reserved.
//

#import "MessageData.h"

@implementation MessageData

- (id)initWithDictionary:(NSDictionary*)messageDict
{
    self = [super init];
    
    if (self && messageDict != nil)
    {
        self.body = [messageDict valueForKey:@"body"];
        self.username = [messageDict valueForKey:@"username"];
        self.name = [messageDict valueForKey:@"Name"];
        self.imageUrl = [messageDict valueForKey:@"image-url"];
        self.messageTime = [messageDict valueForKey:@"message-time"];
    }
    
    return self;
}
@end
