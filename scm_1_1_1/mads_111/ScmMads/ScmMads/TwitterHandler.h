//
//  TwitterHandler.h
//  SecondCommercialsAd
//
//  Created by YM on 7/31/12.
//
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface TwitterHandler : NSObject {
    TWTweetComposeViewController *twController; 
    TWRequest *twRequest;
    ACAccountStore *accountStore;
    ACAccount *twAccount;
}

@property (nonatomic, strong) TWTweetComposeViewController *twController;
@property (nonatomic, strong) TWRequest *twRequest;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *twAccount;
@property (nonatomic, assign) BOOL isTwitterLogin;


- (void) twLogin;
- (void) twSendUpdate: (NSString *)twPost;
- (void) twSendDirectMessage: (NSString *) twDirectMessage;

@end
