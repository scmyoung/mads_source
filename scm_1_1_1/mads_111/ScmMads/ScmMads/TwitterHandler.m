//
//  TwitterHandler.m
//  SecondCommercials Mads
//
//  Created by YM on 8/23/12.
//
//

#import "TwitterHandler.h"

@implementation TwitterHandler


@synthesize twController;
@synthesize twAccount;
@synthesize twRequest;
@synthesize accountStore;
@synthesize isTwitterLogin;


- (id) init
{
    self = [super init];
    
    self.twController = [[TWTweetComposeViewController alloc]init]; 
    self.accountStore = [[ACAccountStore alloc] init];
    self.twAccount = nil;
    self.isTwitterLogin = NO;
    
    return self;
}

- (void) twLogin
{
    /*
    if (![TWTweetComposeViewController canSendTweet]) {
    
        
    } else {
    */
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
            if(granted) {
                NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
                if ([accountsArray count] > 0) {
                    NSLog(@"Granted and has account");
                    twAccount = [accountsArray objectAtIndex:0];
                    isTwitterLogin = YES;
                }
            }
        }];
    
}

- (void) twSendUpdate: (NSString *)twPost
{
    
    NSLog(@"send twitter message 2");
    
    twRequest = [[TWRequest alloc]initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"] parameters:[NSDictionary dictionaryWithObject:twPost forKey:@"status"] requestMethod:TWRequestMethodPOST];
    
    [twRequest setAccount:twAccount];
    [twRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"[scm]: - Twitter Update Response, HTTP response: %i", [urlResponse statusCode]);
        NSString* newStr = [[NSString alloc] initWithData:responseData
                                                 encoding:NSUTF8StringEncoding];
        NSLog(@"[scm] - Twitter Update Request Response Data: %@", newStr);
        if (!error) {
            NSLog(@"[scm] - Twitter Update Error with: %@", [error description]);
        }
    }];
}


- (void) twSendDirectMessage: (NSString *) twDirectMessage
{
    twRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1/direct_messages/new.json"] parameters:[NSDictionary dictionaryWithObjectsAndKeys:twAccount.username,@"screen_name",twDirectMessage,@"text", nil] requestMethod:TWRequestMethodPOST];
    
    [twRequest setAccount:twAccount];
    [twRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"[scm]: - Twitter Send DM response, HTTP response: %i", [urlResponse statusCode]);
        NSString* newStr = [[NSString alloc] initWithData:responseData
                                                 encoding:NSUTF8StringEncoding];
        NSLog(@"[scm] - Twitter Send DM Request Response Data: %@", newStr);
        if (!error) {
            NSLog(@"[scm] - Twitter Send DM Error with: %@", [error description]);
        }
    }];
}

@end


