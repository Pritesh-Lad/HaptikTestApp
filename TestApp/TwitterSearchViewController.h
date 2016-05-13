//
//  TwitterSearchViewController.h
//  TestApp
//
//  Created by Pritesh Lad on 10/05/16.
//  Copyright © 2016 Test. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterSearchViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{

}
@property (weak, nonatomic) IBOutlet UITableView *tweetsTableView;

@end
