//
//  MessageData.h
//  TestApp
//
//  Created by Pritesh Lad on 11/05/16.
//  Copyright © 2016 Test. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageData : NSObject
{

}

@property(nonatomic, strong) NSString* body;
@property(nonatomic, strong) NSString* username;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* imageUrl;
@property(nonatomic, strong) NSString* messageTime;

- (id)initWithDictionary:(NSDictionary*)messageDict;

@end
