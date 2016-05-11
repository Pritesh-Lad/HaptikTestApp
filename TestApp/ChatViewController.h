//
//  ChatViewController.h
//  TestApp
//
//  Created by Pritesh Lad on 10/05/16.
//  Copyright © 2016 Test. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *topperLabel;
@property (weak, nonatomic) IBOutlet UILabel *runnerLabel;
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@end
