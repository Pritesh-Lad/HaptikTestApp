//
//  StringsViewController.h
//  TestApp
//
//  Created by Pritesh Lad on 10/05/16.
//  Copyright © 2016 Test. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StringsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *inputField;

- (IBAction)verifyString:(id)sender;
@end
