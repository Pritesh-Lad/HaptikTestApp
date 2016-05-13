//
//  TweetData.h
//  TestApp
//
//  Created by Pritesh Lad on 13/05/16.
//  Copyright © 2016 Test. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetData : NSObject
{

}

@property (nonatomic, strong) NSString *tweetText;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *profileImageUrl;
@property (nonatomic, strong) NSString *dateString;


- (id)initWithDictionary:(NSDictionary*)tweetDict;
@end
