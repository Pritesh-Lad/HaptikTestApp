//
//  TwitterSearchViewController.m
//  TestApp
//
//  Created by Pritesh Lad on 10/05/16.
//  Copyright © 2016 Test. All rights reserved.
//

/*
 Build a twitter search client which searches for all the tweets which contain the word ‘iOS’. This will include you creating an app on Twitter Developer Console and getting the Auth Keys. Fetch the search data and save it to Core Data and display it on a UITableView.
 
 Consumer Key (API Key) ZaUy9YTiaVCGCdO8MBHeA6KZz
 Consumer Secret (API Secret) A3s9pUcywUcFmFtxwnqJ5oxmoIx9fcy1b1sQCAIKoA6r3GxnCA
 
 
 Access Token 159859555-J0AZCzs28EWbdOXS6b4WZ7MmRi4vTeIO2f8YxKpk
 Access Token Secret WsaUsEaetlgKUSoH2Nlz6k0VQ1206F2SPQMy6rc6dypgs
 */

#import "TwitterSearchViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#define CONSUMER_KEY @"ZaUy9YTiaVCGCdO8MBHeA6KZz"
#define CONSUMER_SECRET @"A3s9pUcywUcFmFtxwnqJ5oxmoIx9fcy1b1sQCAIKoA6r3GxnCA"

@interface TwitterSearchViewController ()

@property (nonatomic,strong) NSMutableArray *results;
@property (nonatomic,strong) ACAccountStore *accountStore;

@end

@implementation TwitterSearchViewController

- (ACAccountStore *)accountStore
{
    if (_accountStore == nil)
    {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self requestAuthToken];
    
    
//    [self loadQuery];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestAuthToken
{
    NSString *urlString = @"http://api.twitter.com/oauth2/token/";
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    
    
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response, NSError *error)
                                      {
                                          NSLog(@"Response:- \n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                          
                                          //Received response.
                                          NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                          
                                          [self performSelectorOnMainThread:@selector(showMessagesFromResponse:) withObject:jsonResponse waitUntilDone:NO];
                                      }];
    
    [dataTask resume];
}

- (void)loadQuery
{
    NSString *query = @"iOS";
    NSString *encodedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
             NSDictionary *parameters = @{@"q" : encodedQuery};
             
             SLRequest *slRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                       requestMethod:SLRequestMethodGET
                                                                 URL:url
                                                          parameters:parameters];
             
             NSArray *accounts = [self.accountStore accountsWithAccountType:accountType];
             slRequest.account = [accounts lastObject];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

             [slRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 
                 NSError *jsonParsingError = nil;
                 NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonParsingError];
                 
                 self.results = jsonResults[@"statuses"];
                 
                 if ([self.results count] == 0)
                 {
                     NSArray *errors = jsonResults[@"errors"];
                     NSLog(@"Error occured :\n%@", errors);
                 }
                 
                 NSLog(@"jsonResults:\n%@", jsonResults);
             }];
         }
         else
         {
             NSLog(@"Permission rejected");
         }
     }];
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
