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
#import "TweetData.h"
#import "TweetsCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"

#define CONSUMER_KEY @"ZaUy9YTiaVCGCdO8MBHeA6KZz"
#define CONSUMER_SECRET @"A3s9pUcywUcFmFtxwnqJ5oxmoIx9fcy1b1sQCAIKoA6r3GxnCA"

@interface TwitterSearchViewController ()
{
    NSMutableArray *tweets;
}

@property (nonatomic,strong) NSMutableArray *results;

@end

@implementation TwitterSearchViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Tweeter Search : 'iOS'";
    [self requestAuthToken];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestAuthToken
{
    NSString *tokenCredentials = [NSString stringWithFormat:@"%@:%@", CONSUMER_KEY, CONSUMER_SECRET];
    NSString *base64TokenCreds = [[tokenCredentials dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth2/token/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    request.HTTPMethod = @"POST";
    
    [request addValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    [request addValue:[NSString stringWithFormat:@"Basic %@", base64TokenCreds] forHTTPHeaderField:@"Authorization"];
    
    NSString *body = @"grant_type=client_credentials";
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response, NSError *error)
    {
        //Received response.
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if ([[jsonResponse valueForKey:@"token_type"] isEqualToString:@"bearer"])
        {
            NSString *accessToken = [jsonResponse valueForKey:@"access_token"];
            [self loadQueryWithBearerToken:accessToken];
        }
    }];
    
    [dataTask resume];
}

- (void)loadQueryWithBearerToken:(NSString*)bearerToken
{
    NSString *query = @"iOS";
    NSString *encodedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/search/tweets.json?q=%@&lang=en", encodedQuery]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", bearerToken] forHTTPHeaderField:@"Authorization"];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response, NSError *error)
    {
        //Received response.
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSArray *statuses = [jsonResponse valueForKey:@"statuses"];
        
        if (statuses != nil && statuses.count > 0)
        {
            //Save results in DB
            NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:statuses];
            
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            NSManagedObjectContext *context = [appDelegate managedObjectContext];
            
            NSManagedObject *searchResultsObj = [NSEntityDescription insertNewObjectForEntityForName:@"Tweets" inManagedObjectContext:context];

            [searchResultsObj setValue:arrayData forKey:@"searchResults"];
            
            if (![context save:&error]) {
                NSLog(@"Unable to save managed object context.");
                NSLog(@"%@, %@", error, error.localizedDescription);
            }
            
            //Retrieve results from DB
            NSEntityDescription *entityDesc =
            [NSEntityDescription entityForName:@"Tweets"
                        inManagedObjectContext:context];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:entityDesc];
            
            NSArray *fetchedArray = [context executeFetchRequest:fetchRequest error:&error];
            if ( fetchedArray.count > 0) {
                searchResultsObj = [fetchedArray lastObject];
                NSData *dbData = (NSData*)[searchResultsObj valueForKey:@"searchResults"];
                statuses = [NSKeyedUnarchiver unarchiveObjectWithData:dbData];
            }
            
            NSMutableArray *searches = [[NSMutableArray alloc] init];
            for (NSDictionary *tweetDict in statuses) {
                TweetData *tweet = [[TweetData alloc] initWithDictionary:tweetDict];
                [searches addObject:tweet];
            }
            
            [tweets removeAllObjects];
            tweets = searches;
            
            //Reload data
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.tweetsTableView reloadData];
            });
        }
        
//        tweets = [[NSMutableArray alloc] init];
//        
//        for (NSDictionary *tweetDict in statuses) {
//            TweetData *tweet = [[TweetData alloc] initWithDictionary:tweetDict];
//            [tweets addObject:tweet];
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tweetsTableView reloadData];
//        });
    }];
    
    [dataTask resume];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tweets.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetData *tweet = tweets[indexPath.row];
    CGRect rect = [tweet.tweetText boundingRectWithSize:CGSizeMake(self.tweetsTableView.bounds.size.width - 80, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:13.0]} context:nil];
    
    return MAX(rect.size.height + 60, 90);
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetsCell"];
    TweetData *tweet = tweets[indexPath.row];
    [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:tweet.profileImageUrl] placeholderImage:nil];
    cell.userNameLabel.text = tweet.userName;
    
    CGRect rect = [tweet.tweetText boundingRectWithSize:CGSizeMake(self.tweetsTableView.bounds.size.width - 80, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:13.0]} context:nil];
    
    CGRect tweetFrame = cell.tweetLabel.frame;
    tweetFrame.size.height = ceil(rect.size.height);
    cell.tweetLabel.frame = tweetFrame;
    
    cell.tweetLabel.text = tweet.tweetText;
    cell.dateLabel.text = tweet.dateString;
    
    return  cell;
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
