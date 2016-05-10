//
//  StringsViewController.m
//  TestApp
//
//  Created by Pritesh Lad on 10/05/16.
//  Copyright © 2016 Test. All rights reserved.
//

#import "StringsViewController.h"

@interface StringsViewController ()
{
    NSArray *masterList;
}
@end

@implementation StringsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    masterList = @[@"end", @"back", @"and", @"the", @"po", @"pu", @"lar", @"face"];
    
    self.navigationItem.title = @"String Formation";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)verifyString:(id)sender {
    
    NSString *input = [self.inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (![input isEqualToString:@""]) {
        
        NSMutableString *inputString = input.mutableCopy;
        
        for (NSString *subString in masterList) {
            
            if ([inputString localizedStandardContainsString:subString]) {
                inputString = [inputString stringByReplacingCharactersInRange:[inputString localizedStandardRangeOfString:subString] withString:@""].mutableCopy;
            }
            
            if ([inputString isEqualToString:@""]) {
                //String can be formed.
                [self showAlertWithMessage:@"String can be formed"];
                NSLog(@"String can be formed");
                break;
            }
        }
        
        if (![inputString isEqualToString:@""]) {
            //String can't be formed.
            [self showAlertWithMessage:@"String can't be formed"];
            NSLog(@"String can't be formed");
        }
        
    }
    else
    {
        //Alert
        [self showAlertWithMessage:@"Please enter a string to be verified"];
        NSLog(@"Please enter a string to be verified");
    }
}

- (void)showAlertWithMessage:(NSString*)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
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
