//
//  ScmMads.m
//  ScmMads
//
//  Created by jimmy on 8/9/12.
//  Copyright (c) 2012 SecondCommercials. All rights reserved.
//

#import "ScmMads.h"
#import "Utilities.h"
#import "Macros.h"
#import "TwitterHandler.h"
#import <FacebookSDK/FacebookSDK.h>


@interface ScmMads ()
{
    /*
    UIImageView *stampView_p;   // portrait stamp view
    UIImageView *stampView_l;   // landscape stamp view
    
    UIImageView *snsView_p;     // portrait sns view
    UIImageView *snsView_l;     // landscape sns view
    
    UIButton *twButton_p;
    UIButton *fbButton_p;
    UIButton *twButton_l;
    UIButton *fbButton_l;
    
    UIButton *bannerButton_p;   // portrait banner button
    UIButton *bannerButton_l;   // landscape banner button
    
    UIButton *closeXButton_p;
    UIButton *closeArrowButton_p;
    UIButton *closeXButton_l;
    UIButton *closeArrowButton_l;
     */
    
    UIImageView *stampView_p;
    UIImageView *stampView_l;
    UIImageView *snsView_p;
    UIImageView *snsView_l;
    
    UIButton *bannerButton_p;
    UIButton *bannerButton_l;
    
    
    UIButton *closeXButton_p;
    UIButton *closeXButton_l;
    UIButton *closeXSns_p;
    UIButton *closeXSns_l;
    
    
    UIButton *twtButton_p;
    UIButton *fbButton_p;
    UIButton *twtButton_l;
    UIButton *fbButton_l;
    
    UIButton *twtIcon_p;
    UIButton *twtIcon_l;
    UIButton *fbIcon_p;
    UIButton *fbIcon_l;
    
    
    // ------------------------
    
    // Utility Calss
    Utilities *utilities;
    
    // Orientation
    UIDeviceOrientation currentOrientation;
    
    // campaign name
    NSString *campaignName;
    
    /**** Globals ****/
    NSFileManager *fileMgr;
    
    NSInteger missed_banner_counter;
    NSInteger missed_ad_counter;
    NSString *first_missed_time;
    NSInteger stamp_banner_counter;
    NSInteger stamp_ad_counter;
    NSString *first_stamp_time;
    
    // campaign url
    NSString *campaignUrl;
    
    // Country Code
    NSString *phoneCountryCode;
    NSString *campaignCountryCode;
    
    // hurdle label x,y,w,h
    NSInteger hurdle_x_p;
    NSInteger hurdle_y_p;
    NSInteger hurdle_w_p;
    NSInteger hurdle_h_p;
    
    NSInteger hurdle_x_l;
    NSInteger hurdle_y_l;
    NSInteger hurdle_w_l;
    NSInteger hurdle_h_l;
    
    // NSDictionary to hold XML information
    NSMutableDictionary *dictXmlInfo;
    
    // digital voucher YES or NO
    NSString *digitalVoucher;
    
    // hurdle point for a game
    NSInteger hurdlePoint;
    
    // Twitter Handler
    TWTweetComposeViewController *twController;
    TWRequest *twRequest;
    ACAccountStore *accountStore;
    ACAccount *twAccount;
    TwitterHandler *twHandler;
    
    // Facebook Handler
    FBSession *fbSession;
    
    NSString *fb_email;
    NSString *fb_name;
    
    NSString *tw_username;
    

    
    // Booleans
    BOOL isCountryCodeMatch;
    BOOL isDownloading;
    BOOL isDownloadOk;
    BOOL isInternetAvailable;
    BOOL isNoCampaignView;
    BOOL isMissedView;
    
    BOOL isSnsLoginView;
    BOOL isFacebookLogin;
    BOOL isTwitterLogin;
    
    BOOL isPortraitMode;
}

@end


@implementation ScmMads

@synthesize scmMadsDelegate;

- (void) clearCampaignFiles : (NSArray *)clearFiles
{
    for (NSInteger i=0; i<clearFiles.count; i++) {
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:[clearFiles objectAtIndex:i]];
        
        if ([fileMgr fileExistsAtPath:filePath]) {
            [fileMgr removeItemAtPath:filePath error:nil];
        }
    }
    
    // Remove PLIST too
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
    if ([fileMgr fileExistsAtPath:filePath]) {
        [fileMgr removeItemAtPath:filePath error:nil];
    }
}


- (void) parseScmPlistFile
{
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
    if ([fileMgr fileExistsAtPath:filePath]) {
        dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        campaignName = [dictXmlInfo objectForKey:@"campaign"];
        digitalVoucher = [dictXmlInfo objectForKey:@"digitalVoucher"];
        hurdlePoint = [[dictXmlInfo objectForKey:@"hurdle"] intValue];;
        
        missed_banner_counter   = [[dictXmlInfo objectForKey:@"missed_banner_imp"] intValue];
        missed_ad_counter       = [[dictXmlInfo objectForKey:@"missed_banner_click"] intValue];
        first_missed_time       = [dictXmlInfo objectForKey:@"first_missed_time"];
        stamp_banner_counter   = [[dictXmlInfo objectForKey:@"stamp_banner_imp"] intValue];
        stamp_ad_counter       = [[dictXmlInfo objectForKey:@"stamp_banner_click"] intValue];
        first_stamp_time        = [dictXmlInfo objectForKey:@"first_stamp_time"];
        
        
        campaignUrl = [dictXmlInfo objectForKey:@"campaignUrl"];
        campaignCountryCode = [dictXmlInfo objectForKey:@"countryCode"];
        NSLog(@"[scm]: campaign country code: %@", campaignCountryCode);
        
        
        hurdle_x_p = [[dictXmlInfo objectForKey:@"hurdle_x_p"] intValue];
        hurdle_y_p = [[dictXmlInfo objectForKey:@"hurdle_y_p"] intValue];
        hurdle_w_p = [[dictXmlInfo objectForKey:@"hurdle_w_p"] intValue];
        hurdle_h_p = [[dictXmlInfo objectForKey:@"hurdle_h_p"] intValue];
        
        hurdle_x_l = [[dictXmlInfo objectForKey:@"hurdle_x_l"] intValue];
        hurdle_y_l = [[dictXmlInfo objectForKey:@"hurdle_y_l"] intValue];
        hurdle_w_l = [[dictXmlInfo objectForKey:@"hurdle_w_l"] intValue];
        hurdle_h_l = [[dictXmlInfo objectForKey:@"hurdle_h_l"] intValue];
        
        dictXmlInfo = nil;
    } else {
        hurdlePoint = 0;
        digitalVoucher = @"NO";
        campaignName = @"NoCampaign";
        
        missed_banner_counter   = 0;
        missed_ad_counter       = 0;
        stamp_banner_counter   = 0;
        stamp_ad_counter       = 0;
        
        first_missed_time   = @"0000-00-00 00:00:00";
        first_stamp_time    = @"0000-00-00 00:00:00";
        
        campaignUrl = @"http://naver.com";
        campaignCountryCode = @"SG";
        
        hurdle_x_p = 30;
        hurdle_y_p = 350;
        hurdle_w_p = 260;
        hurdle_h_p = 20;
        
        hurdle_x_l = 108;
        hurdle_y_l = 240;
        hurdle_w_l = 264;
        hurdle_h_l = 20;
    }
}

- (void) syncToServer
{
    [self parseScmPlistFile];
    
    NSString* appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* deviceId = [[UIDevice currentDevice] uniqueIdentifier];
    
    NSString *baseUrl = @"http://211.115.71.69/logic/mads_3_1_0.php";
    baseUrl = [baseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:baseUrl];
            
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *params = [[NSString alloc] initWithFormat:@"id=M.AD.S&passwd=qkrtkdwls78!"];
    
    params = [params stringByAppendingFormat:@"&DeviceID=%@", deviceId];
    params = [params stringByAppendingFormat:@"&AppID=%@", appId];
    params = [params stringByAppendingFormat:@"&campaignName=%@", campaignName];
    params = [params stringByAppendingFormat:@"&digitalVoucher=%@", digitalVoucher];
    params = [params stringByAppendingFormat:@"&hurdle=%@", [NSNumber numberWithInteger:hurdlePoint]];
    params = [params stringByAppendingFormat:@"&CountryCode=%@", phoneCountryCode];
    
    params = [params stringByAppendingFormat:@"&missed_banner_imp=%@", [NSNumber numberWithInteger:missed_banner_counter]];
    params = [params stringByAppendingFormat:@"&missed_banner_click=%@", [NSNumber numberWithInteger:missed_ad_counter]];
    params = [params stringByAppendingFormat:@"&first_missed_time=%@", first_missed_time];
    params = [params stringByAppendingFormat:@"&stamp_banner_imp=%@", [NSNumber numberWithInteger:stamp_banner_counter]];
    params = [params stringByAppendingFormat:@"&stamp_banner_click=%@", [NSNumber numberWithInteger:stamp_ad_counter]];
    params = [params stringByAppendingFormat:@"&first_stamp_time=%@", first_stamp_time];

    
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    [request setTimeoutInterval:2.0f];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([data length] > 0 && error == nil)
    {
        NSLog(@"[scm]: Response - %@", responseStr);
        
        if ([responseStr isEqualToString:@"NoCampaign"]) {
            NSLog(@"[scm]: No Campaign Available!");
            isNoCampaignView = YES;
            
            NSArray *defaultFiles = [[NSArray alloc] initWithObjects:IMG_DEFAULT_P, IMG_DEFAULT_L,
                                     IMG_DEFAULT_BANNER_P, IMG_DEFAULT_BANNER_L, IMG_X_MARK, nil];
            [self downloadFiles:defaultFiles campaignPath:@"NoCampaign"];
        
        } else if ([responseStr isEqualToString:@"SameCampaign"]) {
            NSLog(@"[scm]: Same Campaign!");
            isDownloadOk = YES;
        } else if ([responseStr isEqualToString:@"NoCountryCodeMatch"]) {
            NSLog(@"[scm]: Country Code Doesn't Match!");
            isCountryCodeMatch = NO;
        } else if ([responseStr isEqualToString:@"HurdleChange"]) {
            NSLog(@"[scm]: Hurdle Changed!");
            
        } else {
            NSLog(@"[scm]: New Campaign ---- %@", responseStr);
            NSArray *campaignFiles = [[NSArray alloc] initWithObjects:IMG_SNS_CONNECT_P, IMG_STAMP_P, IMG_MISSED_P, IMG_X_MARK, SCM_AD_XML, IMG_DEFAULT_P, IMG_SNS_CONNECT_L, IMG_STAMP_L, IMG_MISSED_L, IMG_DEFAULT_L, IMG_TWT_MARK, IMG_FB_MARK, IMG_BANNER_MISSED_L, IMG_BANNER_MISSED_P, IMG_BANNER_L, IMG_BANNER_P, nil];
            [self downloadFiles:campaignFiles campaignPath:responseStr];
        }
        isInternetAvailable = YES;
    } else if ([data length] ==0 && error == nil) {
        NSLog(@"No Data");
    } else if  (error) {
        NSLog(@"Error: %@", error.description);
    }

}

- (id) initScmMads
{
    NSLog(@"[scm]: Init ScmMads!");
    
    self=[super init];
    
    self.view.frame = CGRectMake(0, -530, 480, 530);
    [self.view setUserInteractionEnabled:YES];
    
    // ------------- Initiate Properties ----------
    fileMgr = [[NSFileManager alloc] init];
    utilities = [[Utilities alloc] init];
    phoneCountryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    // Twitter Initiation
    twHandler = [[TwitterHandler alloc] init];
    twController = [[TWTweetComposeViewController alloc]init];
    accountStore = [[ACAccountStore alloc] init];
    
    isCountryCodeMatch  = YES;
    isDownloading       = NO;
    isDownloadOk        = NO;
    isInternetAvailable = NO;
    isNoCampaignView    = NO;
    isMissedView        = NO;
    
    isSnsLoginView      = NO;
    isFacebookLogin     = NO;
    isTwitterLogin      = NO;
    isPortraitMode      = YES;
    
    // ------------- Initiate UI ------------------
    
    stampView_p = [[UIImageView alloc]init];
    stampView_l = [[UIImageView alloc]init];

    snsView_l = [[UIImageView alloc]init];
    snsView_p = [[UIImageView alloc]init];
    
    bannerButton_p = [UIButton buttonWithType:UIButtonTypeCustom];
    bannerButton_l = [UIButton buttonWithType:UIButtonTypeCustom];
    
    closeXButton_p = [UIButton buttonWithType:UIButtonTypeCustom];
    closeXButton_l = [UIButton buttonWithType:UIButtonTypeCustom];
    
    closeXSns_p = [UIButton buttonWithType:UIButtonTypeCustom];
    closeXSns_l = [UIButton buttonWithType:UIButtonTypeCustom];
    
    twController = [[TWTweetComposeViewController alloc]init];
    accountStore = [[ACAccountStore alloc] init];
    
    twtButton_p = [UIButton buttonWithType:UIButtonTypeCustom];
    fbButton_p = [UIButton buttonWithType:UIButtonTypeCustom];
    twtButton_l = [UIButton buttonWithType:UIButtonTypeCustom];
    fbButton_l = [UIButton buttonWithType:UIButtonTypeCustom];
    twtButton_p.frame = CGRectMake(36, 297, 245, 42);
    twtButton_l.frame = CGRectMake(124, 204, 245, 42);
    fbButton_p.frame = CGRectMake(36, 254, 245, 42);
    fbButton_l.frame = CGRectMake(124, 162, 245, 42);
    
    twtIcon_p = [[UIButton alloc]initWithFrame:CGRectMake(229, 386, 42, 42)];
    twtIcon_l = [[UIButton alloc]initWithFrame:CGRectMake(388, 246, 42, 42)];
    fbIcon_p = [[UIButton alloc]initWithFrame:CGRectMake(187, 386, 42, 42)];
    fbIcon_l = [[UIButton alloc]initWithFrame:CGRectMake(346, 246, 42, 42)];
    
    [twtButton_p addTarget:self action:@selector(scmTwitterLogin) forControlEvents:UIControlEventTouchUpInside];
    [twtButton_l addTarget:self action:@selector(scmTwitterLogin) forControlEvents:UIControlEventTouchUpInside];
    [fbButton_p addTarget:self action:@selector(scmFacebookLogin) forControlEvents:UIControlEventTouchUpInside];
    [fbButton_l addTarget:self action:@selector(scmFacebookLogin) forControlEvents:UIControlEventTouchUpInside];

    
    // ------------- Orientation Events Registration ------------------
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    
    
    // ------------- SNS Initiation -----------------
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_SNS_PLIST];
    if ([fileMgr fileExistsAtPath:filePath]) {
        dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        isFacebookLogin = [[dictXmlInfo objectForKey:@"isFacebookLogin"] boolValue];
        isTwitterLogin = [[dictXmlInfo objectForKey:@"isTwitterLogin"] boolValue];
        
        if (isFacebookLogin) {
            NSLog(@"is Facebook Login");
        } else {
            NSLog(@"is Facebook Login NO");
        }
    }
    
    if (isFacebookLogin == YES) {
        NSArray *permissions = [NSArray arrayWithObjects:@"publish_stream", @"email", nil];
        [FBSession sessionOpenWithPermissions:permissions
                            completionHandler:
         ^(FBSession *session,
           FBSessionState status,
           NSError *error) {
             // if login fails for any reason, we alert
             if (error) {
                 // TODO: Handle Facebook Login Error
                 NSLog(@"[scm]: Facebook Login Error!");
             } else if (FB_ISSESSIONOPENWITHSTATE(status)) {
             }
         }];
    }
   
    
    [self createStampView];
    [self syncToServer];
    
    return self;
}


- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    /*
    //Obtaining the current device orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    //Ignoring specific orientations
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown || currentOrientation == orientation) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(relayoutLayers) object:nil];
    //Responding only to changes in landscape or portrait
    currentOrientation = orientation;
    NSLog(@"[scm]: Orientation Changed!");
    
    
    [self createStampView];
    [self hideScmMads];
     */
}


- (void) showScmMads:(NSInteger)points
{
    
    [[self scmMadsDelegate] scmAdBannerWillShow];
        
    // Check for Country Code First
    if (isCountryCodeMatch == NO) {
        NSLog(@"[scm]: Country Code doesn't match");
        return;
    }
    
    if (isDownloading == NO) {
        [self syncToServer];
    }

    if (isDownloadOk == YES) {
        
        // User Document Directory Path
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0];
        [snsView_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_SNS_CONNECT_P]]]];
        [snsView_l setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_SNS_CONNECT_L]]]];
        [closeXButton_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_X_MARK]]] forState:UIControlStateNormal];
        [closeXButton_l setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_X_MARK]]] forState:UIControlStateNormal];
        [closeXSns_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_X_MARK]]] forState:UIControlStateNormal];
        [closeXSns_l setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_X_MARK]]] forState:UIControlStateNormal];
        
        // No Campaign Default View
        if (isNoCampaignView == YES) {
            [stampView_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:
                                                          [docPath stringByAppendingPathComponent:IMG_DEFAULT_P]]]];
            [stampView_l setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:
                                                          [docPath stringByAppendingPathComponent:IMG_DEFAULT_L]]]];


            
            [bannerButton_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_DEFAULT_BANNER_P]]] forState:UIControlStateNormal];
            
            [bannerButton_l setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_DEFAULT_BANNER_L]]] forState:UIControlStateNormal];
            
            
            
        } else if (points >= hurdlePoint) {
            [stampView_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:
                                                          [docPath stringByAppendingPathComponent:IMG_STAMP_P]]]];
            [stampView_l setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:
                                                          [docPath stringByAppendingPathComponent:IMG_STAMP_L]]]];
            [bannerButton_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_BANNER_P]]] forState:UIControlStateNormal];
            
            [bannerButton_l setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_BANNER_L]]] forState:UIControlStateNormal];
            
            // Save stampsCounter to Plist file
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
            if ([fileMgr fileExistsAtPath:filePath]) {
                dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
                [dictXmlInfo setObject:[[NSString alloc] initWithFormat:@"%d", ++stamp_banner_counter] forKey:@"stamp_banner_imp"];
                
                [dictXmlInfo writeToFile:filePath atomically:YES];
                dictXmlInfo = nil;
            }

        } else {
            isMissedView = YES;
            [stampView_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:
                                                          [docPath stringByAppendingPathComponent:IMG_MISSED_P]]]];
            [stampView_l setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:
                                                          [docPath stringByAppendingPathComponent:IMG_MISSED_L]]]];
            
            [bannerButton_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_BANNER_MISSED_P]]] forState:UIControlStateNormal];
            
            [bannerButton_l setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_BANNER_MISSED_L]]] forState:UIControlStateNormal];
            
            // Save stampsCounter to Plist file
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
            if ([fileMgr fileExistsAtPath:filePath]) {
                dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
                [dictXmlInfo setObject:[[NSString alloc] initWithFormat:@"%d", ++missed_banner_counter] forKey:@"missed_banner_imp"];
                
                [dictXmlInfo writeToFile:filePath atomically:YES];
                dictXmlInfo = nil;
            }
        }
        
        [UIView beginAnimations:@"showBanner" context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationDelegate:self];
        
        currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (currentOrientation == UIDeviceOrientationPortrait) {
            bannerButton_l.hidden = YES;
            stampView_l.hidden = YES;
            bannerButton_p.hidden = NO;
            stampView_p.hidden = NO;
            
            self.view.frame = CGRectMake(0, 0, 320, 57);
        }
        else{
            bannerButton_p.hidden = YES;
            stampView_p.hidden = YES;
            bannerButton_l.hidden = NO;
            stampView_l.hidden = NO;
            
            self.view.frame = CGRectMake(0, 0, 480, 57);
        }
        
        [UIView commitAnimations];
        
        isDownloadOk = NO;
        isDownloading = NO;
    }
    
    
}

- (void) hideScmMads
{
    [UIView beginAnimations:@"hideBanner" context:nil];
    [UIView setAnimationDuration:0.6f];
    [UIView setAnimationDelegate:self];
        
    self.view.frame = CGRectMake(0, -57, 320, 57);

    
    [UIView commitAnimations];

    
    isNoCampaignView = NO;
    isDownloadOk = NO;
    isMissedView = NO;
}

- (void) showStamp
{
    [[self scmMadsDelegate] scmAdViewDidFinish];

    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIDeviceOrientationPortrait) {
        self.view.frame = CGRectMake(0, 0, 320, 480);
    } else {
        self.view.frame = CGRectMake(0, 0, 480, 320);
    }
    
    [UIImageView beginAnimations:@"showStamp" context:nil];
    [UIImageView setAnimationDuration:1];
    [UIImageView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(scmAdAnimationFinished:finished:context:)];

    if (orientation == UIDeviceOrientationPortrait) {
        bannerButton_p.hidden = YES;
        stampView_p.frame = CGRectMake(0, 0, 320, 480);
    } else  {
        bannerButton_l.hidden = YES;
        stampView_l.frame = CGRectMake(0, 0, 480, 320);
    }
    
    [UIImageView commitAnimations];
    
}

- (void) hideStamp
{    

    [self buttonHidden:YES];
    
    [UIImageView beginAnimations:@"hideStamp" context:nil];
    [UIImageView setAnimationDuration:1];
    [UIImageView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(scmAdAnimationFinished:finished:context:)];

    stampView_p.frame = CGRectMake(160, 240, 0, 0);
    stampView_l.frame = CGRectMake(240, 160, 0, 0);
    self.view.frame = CGRectMake(0, -57, 320, 57);
    
    [UIImageView commitAnimations];
    
    isNoCampaignView = NO;


}

-(void) hideSnsView
{
    [UIImageView beginAnimations:@"hideBanner" context:nil];
    [UIImageView setAnimationDuration:0.5f];
    [UIImageView setAnimationDelegate:self];

    snsView_p.frame = CGRectMake(0, -480, 320, 480);
    snsView_l.frame = CGRectMake(0, -320, 480, 320);
    
    [UIImageView commitAnimations];
}

- (void) buttonHidden:(BOOL)flag
{
    closeXButton_p.hidden = flag;
    closeXButton_l.hidden = flag;
    
    twtIcon_p.hidden    = flag;
    fbIcon_p.hidden     = flag;
    twtIcon_l.hidden    = flag;
    fbIcon_l.hidden     = flag;
}

- (void) createStampView
{
    
    stampView_p.frame = CGRectMake(160, 240, 0, 0);
    [stampView_p setUserInteractionEnabled:YES];
    
    bannerButton_p.frame = CGRectMake(0, 0, 320, 57);
    closeXButton_p.frame = CGRectMake(247, 32, 42, 42);
    
    [bannerButton_p addTarget:self action:@selector(showStamp) forControlEvents:UIControlEventTouchUpInside];
    [closeXButton_p addTarget:self action:@selector(hideStamp) forControlEvents:UIControlEventTouchUpInside];
    
    self.view.frame = CGRectMake(0, -57, 320, 57);
    [self.view addSubview:bannerButton_p];
    [self.view addSubview:stampView_p];
    [stampView_p addSubview:closeXButton_p];
    [snsView_p addSubview:twtButton_p];
    [snsView_p addSubview:fbButton_p];
    
    
    
    [stampView_l setUserInteractionEnabled:YES];
    stampView_l.frame = CGRectMake(240, 160, 0, 0);

    bannerButton_l.frame = CGRectMake(0, 0, 480, 57);
    closeXButton_l.frame = CGRectMake(410, 32, 42, 42);
    
    snsView_p.frame = CGRectMake(0, -480, 320, 480);
    snsView_l.frame = CGRectMake(0, -320, 480, 320);
    snsView_p.userInteractionEnabled = YES;
    snsView_l.userInteractionEnabled = YES;
    
    
    [bannerButton_l addTarget:self action:@selector(showStamp) forControlEvents:UIControlEventTouchUpInside];
    [closeXButton_l addTarget:self action:@selector(hideStamp) forControlEvents:UIControlEventTouchUpInside];
    [closeXSns_p addTarget:self action:@selector(hideSnsView) forControlEvents:UIControlEventTouchUpInside];
    [closeXSns_l addTarget:self action:@selector(hideSnsView) forControlEvents:UIControlEventTouchUpInside];
    closeXSns_p.frame = CGRectMake(247, 32, 42, 42);
    closeXSns_l.frame = CGRectMake(410, 32, 42, 42);
    
    [twtIcon_p addTarget:self action:@selector(scmTwitterLogin) forControlEvents:UIControlEventTouchUpInside];
    [twtIcon_l addTarget:self action:@selector(scmTwitterLogin) forControlEvents:UIControlEventTouchUpInside];
    [fbIcon_p addTarget:self action:@selector(scmFacebookLogin) forControlEvents:UIControlEventTouchUpInside];
    [fbIcon_l addTarget:self action:@selector(scmFacebookLogin) forControlEvents:UIControlEventTouchUpInside];
    
    [self buttonHidden:YES];
    
    [stampView_p addSubview:twtIcon_p];
    [stampView_l addSubview:twtIcon_l];
    [stampView_p addSubview:fbIcon_p];
    [stampView_l addSubview:fbIcon_l];
    
    [snsView_p addSubview:closeXSns_p];
    [snsView_l addSubview:closeXSns_l];
    [self.view addSubview:bannerButton_l];
    [self.view addSubview:stampView_l];
    [stampView_l addSubview:closeXButton_l];
    [snsView_l addSubview:twtButton_l];
    [snsView_l addSubview:fbButton_l];
    [self.view addSubview:snsView_p];
    [self.view addSubview:snsView_l];
    
}

- (void) downloadFiles:(NSArray *)fileArray campaignPath:(NSString *)campaign
{
    // clear cached campaign files
    //[self clearCampaignFiles:[NSArray arrayWithObjects:IMG_STAMP_L, IMG_STAMP_P, SCM_AD_XML, nil]];
    [self clearCampaignFiles:[NSArray arrayWithObjects:IMG_BANNER_P,IMG_BANNER_MISSED_P,IMG_STAMP_P,IMG_MISSED_P,IMG_BANNER_L,IMG_BANNER_MISSED_L,IMG_STAMP_L,IMG_MISSED_L,SCM_AD_PLIST,SCM_SNS_PLIST,SCM_AD_XML, nil]];
    
    // Download NoCampaign images if files don't exist in the Documentation Directory.
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        isDownloading = YES;
        for (id fileObject in fileArray) {
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:fileObject];
                        
            // If check for file existance
            if ([fileMgr fileExistsAtPath:filePath] == NO) {
                NSLog(@"[scm]: Download ... %@", fileObject);
                
                NSString *strUrl = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@/%@", SERVER_IP,
                                    @"campaign", @"310_campaign", campaign, fileObject];
                NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]];
                [fileData writeToFile:filePath atomically:YES];
                
                if ([fileMgr fileExistsAtPath:filePath] && [fileObject isEqualToString:SCM_AD_XML]) {
                    [utilities parseScmAdXmlFile:fileData];
                }
            }
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            isDownloading = NO;
            isDownloadOk = YES;
            isInternetAvailable = YES;
        });
    });
}


#pragma - animation callback methods
- (void)scmAdAnimationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    
    if ([animationID isEqualToString:@"hideStamp"]) {
        if (isMissedView)
            isMissedView = NO;

        [self syncToServer];
        [[self scmMadsDelegate] scmAdViewDidFinish];
    }
    
    if ([animationID isEqualToString:@"showStamp"] && isNoCampaignView == YES) {
        NSLog(@"[scm]: is No Campaign View");
        [self buttonHidden:YES];
        
        closeXButton_p.hidden = NO;
        closeXButton_l.hidden = NO;
    }
    
    if ([animationID isEqualToString:@"showStamp"] && isNoCampaignView == NO) {
        // Save click impressions
        // Save stampsCounter to Plist file
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
        if ([fileMgr fileExistsAtPath:filePath]) {
            dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
            
            // save stampx_banner_click to plist file
            if (isMissedView) {
                [dictXmlInfo setObject:[[NSString alloc] initWithFormat:@"%d", ++missed_ad_counter] forKey:@"missed_banner_click"];
                
                // check for first_missed_time and assign it if it's 0
                
                NSString *oldDateTime = [dictXmlInfo objectForKey:@"first_missed_time"];
                
                if ([oldDateTime isEqualToString:@"0000-00-00 00:00:00"]) {
                    NSString *dateTime = [utilities getCurrentDateTime];
                    [dictXmlInfo setObject:dateTime forKey:@"first_missed_time"];
                }
                
            } else {
                [dictXmlInfo setObject:[[NSString alloc] initWithFormat:@"%d", 1] forKey:@"stamp_banner_click"];
                
                // Record first stamp time
                NSString *dateTime = [utilities getCurrentDateTime];
                [dictXmlInfo setObject:dateTime forKey:@"first_stamp_time"];
            }
            
            [dictXmlInfo writeToFile:filePath atomically:YES];
            dictXmlInfo = nil;
            
        }
        
        // Show sns view

        if (isMissedView == NO) {
            if ([self checkForPreviouslySavedAccessTokenInfo] == NO && isInternetAvailable == YES) {
                
                [UIView beginAnimations:@"showSnsLoginView" context:nil];
                [UIView setAnimationDuration:1.0f];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDelay:1.0f];
                
                UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
                if (orientation == UIDeviceOrientationPortrait) {
                    snsView_p.frame = CGRectMake(0, 0, 320, 480);
                    [snsView_p setAlpha:1.0f];
                } else  {
                    snsView_l.frame = CGRectMake(0, 0, 480, 320);
                    [snsView_l setAlpha:1.0f];
                }
                
                isSnsLoginView = YES;
                [UIView commitAnimations];
            } else if (isInternetAvailable == YES && isNoCampaignView == NO) {
                if (isFacebookLogin) {
                    [self scmAdPostToFacebook];
                } else if (isTwitterLogin) {
                    [self scmAdPostToTwitter];
                }            
            }

        }
        [self buttonHidden:NO];
        
        
    }
    
    
}

- (BOOL) checkForPreviouslySavedAccessTokenInfo
{
    if (isTwitterLogin == YES || isFacebookLogin == YES) {
        return YES;
    } else {
        return NO;
    }
}

#pragma - send email for facebook user
- (void) sendMailToServer : (NSString *)email_address withName:(NSString *)user_name
{
    NSLog(@"[scm]: send email to facebook account!");
    NSString* appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* deviceId = [[UIDevice currentDevice] uniqueIdentifier];
    NSString* phpFile = [[NSString alloc] initWithFormat:@"%@/logic/facebook_email_logic/sendMailToFacebook_3_1_0.php", SERVER_IP];
    NSURL *url = [NSURL URLWithString:phpFile];

        
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *params = [[NSString alloc] initWithFormat:@"id=SecondCommercials&passwd=second1234567"];
    
    params = [params stringByAppendingFormat:@"&DeviceID=%@", deviceId];
    params = [params stringByAppendingFormat:@"&AppID=%@", appId];
    params = [params stringByAppendingFormat:@"&campaign=%@", campaignName];
    params = [params stringByAppendingFormat:@"&email=%@", email_address];
    params = [params stringByAppendingFormat:@"&name=%@", user_name];
    
    
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    [request setTimeoutInterval:3.0f];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil)
        {
            NSString *responseStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSLog(@"[scm]: Send Email response: %@", responseStr);
        } else {
            NSLog(@"[scm]: Warning - Send email failed!");
        }
    }];
}


- (void)scmAdPostToFacebook
{
        // Post first feed
    if (isMissedView == NO) {
        NSLog(@"SCM - Post to Facebook!");
        NSString *fb_link = nil;
        NSString *fb_link_desc = nil;
        NSString *fb_ad_desc = nil;
        NSString *fb_picture = nil;
        
        NSString *stampText = [[NSString alloc] init];
        
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES)
                               objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
        if ([fileMgr fileExistsAtPath:filePath]) {
            dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
            fb_link = [dictXmlInfo objectForKey:@"fb_link"];
            fb_link_desc = [dictXmlInfo objectForKey:@"fb_link_desc"];
            fb_ad_desc = [dictXmlInfo objectForKey:@"fb_ad_desc"];
            fb_picture = [dictXmlInfo objectForKey:@"fb_picture"];
            
            stampText = [dictXmlInfo objectForKey:@"fb_post"];
            
            dictXmlInfo = nil;
        }
        
        
        if (isInternetAvailable == YES) {
            NSLog(@"[scm]: - Internet is available");
            
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           stampText, @"message", fb_link_desc, @"name", fb_link, @"link", fb_ad_desc,  @"description", fb_picture, @"picture", nil];
            fb_link = nil, fb_link_desc=nil, fb_ad_desc=nil;
            
            //[facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self];
            [FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:
             ^(FBRequestConnection *connection, id result, NSError *error) {
                 if (error) {
                     NSLog(@"[scm]: Post to Facebook Error with: %@", error.description);
                 }
             }];
            
            
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
            if ([fileMgr fileExistsAtPath:filePath]) {
                dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
                [dictXmlInfo setObject:@"YES" forKey:@"digitalVoucher"];
                [dictXmlInfo writeToFile:filePath atomically:YES];
            }
            
            NSString *filePathFB = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_SNS_PLIST];
            if ([fileMgr fileExistsAtPath:filePathFB]) {
                NSMutableDictionary *fbContainer = [[NSMutableDictionary alloc] initWithContentsOfFile:filePathFB];
                fb_email = [fbContainer objectForKey:@"fb_email"];
                fb_name = [fbContainer objectForKey:@"fb_name"];
                // send email to user
                if (fb_email && fb_name) {
                    digitalVoucher = @"YES";
                    [self sendMailToServer:fb_email withName:fb_name];
                    [utilities.alert_dv_fb show];
                }
                
                fbContainer = nil;
            }
            
            NSLog(@"Alert view -----------------");
            [utilities.alert_dv_fb show];
        }
    }
}

-(void)fbDidLogin
{
    NSLog(@"[scm]: - facebook login OK!");
    
    [UIView beginAnimations:@"HideSnsLoginView" context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationDelegate:self];
    
    isSnsLoginView = NO;
    
    snsView_p.frame = CGRectMake(0, -480, 320, 480);
    snsView_l.frame = CGRectMake(0, -320, 480, 320);
    
    [snsView_p setAlpha:0.0f];
    [snsView_l setAlpha:0.0f];
    
    [UIView commitAnimations];

    [self scmAdPostToFacebook];
}


// --- SNS Callbacks
- (void) scmFacebookLogin
{
    NSLog(@"[scm]: Facebook Login");
    
    NSArray *permissions = [NSArray arrayWithObjects:@"publish_stream", @"email", nil];
    [FBSession sessionOpenWithPermissions:permissions
                        completionHandler:
     ^(FBSession *session,
       FBSessionState status,
       NSError *error) {
         // if login fails for any reason, we alert
         if (error) {
             // TODO: Handle Facebook Login Error
             NSLog(@"[scm]: Facebook Login Error!");
         } else if (FB_ISSESSIONOPENWITHSTATE(status)) {
             // send our requests if we successfully logged in
             isFacebookLogin = YES;
             isTwitterLogin = NO;
             
             NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0];
             [twtIcon_l setImage:[UIImage imageWithData:nil] forState:UIControlStateNormal];
             [twtIcon_p setImage:[UIImage imageWithData:nil] forState:UIControlStateNormal];
             [fbIcon_l setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_FB_MARK]]] forState:UIControlStateNormal];
             [fbIcon_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_FB_MARK]]] forState:UIControlStateNormal];
             
             // Get the user's info.
             //[facebook requestWithGraphPath:@"me" andDelegate:self];
             [FBRequestConnection startWithGraphPath:@"me" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                 if ([result isKindOfClass:[NSDictionary class]])
                 {
                     fb_email = [result objectForKey: @"email"];
                     fb_name = [result objectForKey: @"name"];
                     //NSString *facebookId = [result objectForKey: @"id"];
                     //NSLog(@"Facebook Email: %@", fb_email);
                     //NSLog(@"Facebook Name: %@", fb_name);
                     //NSLog(@"FacebookID: %@", facebookId);
                     
                     NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_SNS_PLIST];
                     
                     NSMutableDictionary *fbContainer = [[NSMutableDictionary alloc] init];
                     if (fb_email && fb_name) {
                         //NSLog(@"Write FB Info");
                         [fbContainer setObject:fb_email forKey:@"fb_email"];
                         [fbContainer setObject:fb_name forKey:@"fb_name"];
                         [fbContainer setObject:@"YES" forKey:@"isFacebookLogin"];
                         [fbContainer setObject:@"NO" forKey:@"isTwitterLogin"];

                         [fbContainer writeToFile:filePath atomically:YES];
                     }
                     fbContainer = nil;
                     [self fbDidLogin];

                }
             }];
             

         }
     }];
}

- (void) twSendUpdate: (NSString *)twPost
{
    
    NSLog(@"[scm]: post a twitter message");
    
    twRequest = [[TWRequest alloc]initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"] parameters:[NSDictionary dictionaryWithObject:twPost forKey:@"status"] requestMethod:TWRequestMethodPOST];
    
    [twRequest setAccount:twAccount];
    [twRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (!error) {
            //NSLog(@"[scm] - Twitter Update Error with: %@", [error description]);
        }
    }];
    
}


- (void) twSendDirectMessage: (NSString *) twDirectMessage
{
    twRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1/direct_messages/new.json"] parameters:[NSDictionary dictionaryWithObjectsAndKeys:twAccount.username,@"screen_name",twDirectMessage,@"text", nil] requestMethod:TWRequestMethodPOST];
    
    [twRequest setAccount:twAccount];
    [twRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        //NSLog(@"[scm]: - Twitter Send DM response, HTTP response: %i", [urlResponse statusCode]);
        //NSString* newStr = [[NSString alloc] initWithData:responseData
        //                                         encoding:NSUTF8StringEncoding];
        //NSLog(@"[scm] - Twitter Send DM Request Response Data: %@", newStr);
        
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
        if ([fileMgr fileExistsAtPath:filePath]) {
            dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
            [dictXmlInfo setObject:@"YES" forKey:@"digitalVoucher"];
            [dictXmlInfo writeToFile:filePath atomically:YES];
        }
        if (!error) {
            //NSLog(@"[scm] - Twitter Send DM Error with: %@", [error description]);
        }
    }];
    
}

- (void) scmAdPostToTwitter
{
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            if ([accountsArray count] > 0) {
                isFacebookLogin = NO;
                isTwitterLogin = YES;
                NSLog(@"post twt ~~~~~~~~~~~~~~~~~~~");
                NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0];
                [twtIcon_l setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_TWT_MARK]]] forState:UIControlStateNormal];
                [twtIcon_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_TWT_MARK]]] forState:UIControlStateNormal];
                [fbIcon_l setImage:[UIImage imageWithData:nil] forState:UIControlStateNormal];
                [fbIcon_p setImage:[UIImage imageWithData:nil] forState:UIControlStateNormal];
                
                NSLog(@"[scm]: access twitter account and publish tweet post with dm!");
                twAccount = [accountsArray objectAtIndex:0];
                
                if (isMissedView == NO) {
                    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES)
                                           objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
                    
                    if ([fileMgr fileExistsAtPath:filePath]) {
                        dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
                        
                        NSString *stampText = [[dictXmlInfo objectForKey:@"tw_post"]
                                               stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        NSLog(@"twitter message: %@", stampText);
                        [self twSendUpdate:stampText];
                        
                        NSString *dmText = [[dictXmlInfo objectForKey:@"tw_dm"]
                                            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        [self twSendDirectMessage:dmText];
                        [utilities.alert_dv_tw show];
                        
                        dictXmlInfo = nil;
                    }
                    
                }
                
            }
        }
    }];
}

- (void) scmTwitterLogin
{
    NSLog(@"[scm]: Twitter Login");
    
    if (![TWTweetComposeViewController canSendTweet]) {
        twController = [[TWTweetComposeViewController alloc]init];
        twController.view.hidden = YES;

        [twController.view removeFromSuperview];
        [self presentModalViewController:twController animated:YES];
        [twController.view endEditing:YES];
        
    } else {
        [UIView beginAnimations:@"HideSnsLoginView" context:nil];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationDelegate:self];
        
        isSnsLoginView = NO;
        
        snsView_p.frame = CGRectMake(0, -480, 320, 480);
        snsView_l.frame = CGRectMake(0, -320, 480, 320);
        
        [snsView_p setAlpha:0.0f];
        [snsView_l setAlpha:0.0f];
        
        [UIView commitAnimations];
        
        dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:SCM_SNS_PLIST];
        [dictXmlInfo setObject:@"YES" forKey:@"isTwitterLogin"];
        [dictXmlInfo setObject:@"NO" forKey:@"isFacebookLogin"];
        
        // Facebook Logout
        [FBSession.activeSession closeAndClearTokenInformation];


        [dictXmlInfo writeToFile:SCM_SNS_PLIST atomically:YES];

        [self scmAdPostToTwitter];

    }
}


@end











