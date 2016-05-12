//
//  ChatViewController.m
//  TestApp
//
//  Created by Pritesh Lad on 10/05/16.
//  Copyright © 2016 Test. All rights reserved.
//

/*
 The API endpoint provided below returns data regarding a chat conversation between a group of people.  Your assignment is to use that endpoint to build an iOS app which meets the below requirements
 
 1. The app should showcase the actual conversation that took place between the users.
 2. The app should show the top 2 people who have sent the most number of messages
 
 API Endpoint: http://haptik.co/android/test_data/
 
 Feel free to use any libraries of your choice, which is actively encouraged. You will be judged on your code’s architecture, adherence to iOS HIG guidelines as well as logic.
 */

#import "ChatViewController.h"
#import "MessageData.h"
#import "MessageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ChatViewController ()
{
    NSMutableArray *messageList;
    NSMutableDictionary *participants;
}
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Chat Conversation";

    NSString *urlString = @"http://haptik.co/android/test_data/";
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response, NSError *error)
    {
        NSLog(@"Response:- \n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                          
        //Received response.
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        [self performSelectorOnMainThread:@selector(showMessagesFromResponse:) withObject:jsonResponse waitUntilDone:NO];
        
        NSLog(@"jsonResponse: \n%@", error);
        
    }];
    
    [dataTask resume];
    
}

- (void)showMessagesFromResponse:(NSDictionary*)respDict
{
    messageList = [[NSMutableArray alloc] init];
    participants = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *messageDict in [respDict valueForKey:@"messages"])
    {
        MessageData *message = [[MessageData alloc] initWithDictionary:messageDict];
        
        if ([participants objectForKey:message.name]) {
            NSNumber *messageCount = participants[message.name];
            participants[message.name] = [NSNumber numberWithInt:messageCount.intValue+1];
        }
        else
        {
            participants[message.name] = [NSNumber numberWithInt:1];
        }
        
        [messageList addObject:message];
    }
    
    NSNumber *topper = @0;
    NSString *topperName = @"";
    
    NSNumber *runner = @0;
    NSString *runnerName = @"";
    
    for (NSString *key in [participants allKeys])
    {
        if (participants[key] > topper) {
            runner = topper;
            runnerName = topperName;
            topper = participants[key];
            topperName = key;
        }
        else if (participants[key] > runner)
        {
            runner = participants[key];
            runnerName = key;
        }
    }
    
    self.topperLabel.text = [NSString stringWithFormat:@"%@ - %ld messages", topperName, [(NSNumber*)participants[topperName] longValue]];
    self.runnerLabel.text = [NSString stringWithFormat:@"%@ - %ld messages", runnerName, [(NSNumber*)participants[runnerName] longValue]];
    
    NSLog(@"Top 2 participants:\n %@\n%@", topperName, runnerName);
    
    if (messageList.count > 0)
    {
        //Load messages.
        [self.chatTableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return messageList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageData *message = messageList[indexPath.row];
    CGRect rect = [message.body boundingRectWithSize:CGSizeMake(self.chatTableView.bounds.size.width - 60, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:15.0]} context:nil];
    
    return MAX(rect.size.height + 30, 60);
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *messageCell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    MessageData *message = messageList[indexPath.row];

    CGRect rect = [message.body boundingRectWithSize:CGSizeMake(self.chatTableView.bounds.size.width - 60, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:15.0]} context:nil];
    
    CGRect nameRect = [message.name boundingRectWithSize:CGSizeMake(self.chatTableView.bounds.size.width - 60, 20) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]} context:nil];
    
    messageCell.gradientView.frame = CGRectMake(50, (messageCell.bounds.size.height - rect.size.height - 20)/2, MAX(rect.size.width, nameRect.size.width) + 10, rect.size.height + 20);
    
    CGRect nameFrame = messageCell.nameLabel.frame;
    nameFrame.size.width = messageCell.gradientView.frame.size.width;
    messageCell.nameLabel.frame = nameFrame;
    
    CGRect bodyFrame = messageCell.messageLabel.frame;
    bodyFrame.size = CGSizeMake(rect.size.width, rect.size.height);
    messageCell.messageLabel.frame = bodyFrame;
    
    messageCell.messageLabel.text = message.body;
    messageCell.nameLabel.text = message.name;
    
    [messageCell.userImage sd_setImageWithURL:[NSURL URLWithString:message.imageUrl] placeholderImage:nil];
    
    return messageCell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
