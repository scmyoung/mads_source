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
}

@end


@implementation ScmMads

@synthesize scmMadsDelegate;

- (void) clearCampaignFiles : (NSArray *)clearFiles
{
    for (int i=0; i<clearFiles.count; i++) {
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
                                     IMG_ARROW, IMG_X_MARK, nil];
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
            NSArray *campaignFiles = [[NSArray alloc] initWithObjects:IMG_ARROW, IMG_SNS_CONNECT_P, IMG_STAMP_P, IMG_MISSED_P, IMG_X_MARK, SCM_AD_XML, IMG_DEFAULT_P, IMG_SNS_CONNECT_L, IMG_STAMP_L, IMG_MISSED_L, IMG_DEFAULT_L, nil];
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
    
    // ------------- Initiate UI ------------------
    
    stampView_p = [[UIImageView alloc]init];
    stampView_l = [[UIImageView alloc]init];

    snsView_p = [[UIImageView alloc]init];
    snsView_l = [[UIImageView alloc]init];
     
    bannerButton_p = [UIButton buttonWithType:UIButtonTypeCustom];
    bannerButton_l = [UIButton buttonWithType:UIButtonTypeCustom];

    closeArrowButton_p = [UIButton buttonWithType:UIButtonTypeCustom];
    closeArrowButton_l = [UIButton buttonWithType:UIButtonTypeCustom];
    
    closeXButton_p = [UIButton buttonWithType:UIButtonTypeCustom];
    closeXButton_l = [UIButton buttonWithType:UIButtonTypeCustom];
    
    twButton_p = [UIButton buttonWithType:UIButtonTypeCustom];
    fbButton_p = [UIButton buttonWithType:UIButtonTypeCustom];
    twButton_l = [UIButton buttonWithType:UIButtonTypeCustom];
    fbButton_l = [UIButton buttonWithType:UIButtonTypeCustom];
    
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
        [closeArrowButton_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_ARROW]]] forState:UIControlStateNormal];
        [closeXButton_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_X_MARK]]] forState:UIControlStateNormal];
        [closeArrowButton_l setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_ARROW]]] forState:UIControlStateNormal];
        [closeXButton_l setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_X_MARK]]] forState:UIControlStateNormal];
        
        // No Campaign Default View
        if (isNoCampaignView == YES) {
            [stampView_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:
                                                          [docPath stringByAppendingPathComponent:IMG_DEFAULT_P]]]];
            [stampView_l setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:
                                                          [docPath stringByAppendingPathComponent:IMG_DEFAULT_L]]]];
            
        } else if (points >= hurdlePoint) {
            [stampView_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:
                                                          [docPath stringByAppendingPathComponent:IMG_STAMP_P]]]];
            [stampView_l setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:
                                                          [docPath stringByAppendingPathComponent:IMG_STAMP_L]]]];
            
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
            
            // Save stampsCounter to Plist file
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
            if ([fileMgr fileExistsAtPath:filePath]) {
                dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
                [dictXmlInfo setObject:[[NSString alloc] initWithFormat:@"%d", ++missed_banner_counter] forKey:@"missed_banner_imp"];
                
                [dictXmlInfo writeToFile:filePath atomically:YES];
                dictXmlInfo = nil;
            }
        }
    
        isDownloading = NO;
    }
    
     currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (currentOrientation == UIDeviceOrientationPortrait) {
        stampView_p.hidden = NO;
        stampView_l.hidden = YES;
    } else  {
        stampView_p.hidden = YES;
        stampView_l.hidden = NO;
    }
    
    [UIImageView beginAnimations:@"showBanner" context:nil];
    [UIImageView setAnimationDuration:0.5f];
    [UIImageView setAnimationDelegate:self];
    
    // self.view.frame = CGRectMake(0, -480, 320, 550);
    // [UIImageView commitAnimations];
    
    [UIView animateWithDuration:0.5 animations:^{ self.view.frame = CGRectMake(0, -470, 480, 530); } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{ self.view.frame = CGRectMake (0, -480, 480, 530); } completion:^(BOOL finished) {
            /*NSLog(@"Animation Finished");*/}];
    }];
    [UIView commitAnimations];

}

- (void) hideScmMads
{
    [UIView beginAnimations:@"hideBanner" context:nil];
    [UIView setAnimationDuration:0.6f];
    [UIView setAnimationDelegate:self];
        
    self.view.frame = CGRectMake(0, -530, 320, 530);
        
    [UIView commitAnimations];

    
    isNoCampaignView = NO;
    isDownloadOk = NO;
    isMissedView = NO;
}

- (void) showStamp
{    
    [UIImageView beginAnimations:@"showStamp" context:nil];
    [UIImageView setAnimationDuration:1];
    [UIImageView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(scmAdAnimationFinished:finished:context:)];

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIDeviceOrientationPortrait) {
        self.view.frame = CGRectMake(0, 0, 480, 530);
    } else  {
        self.view.frame = CGRectMake(0, -160, 480, 530);
    }
    
    [UIImageView commitAnimations];
}

- (void) hideStamp
{    
    if (isSnsLoginView == YES) {
        [UIView beginAnimations:@"HideSnsLoginView" context:nil];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationDelegate:self];
        
        isSnsLoginView = NO;
        
        snsView_p.frame = CGRectMake(0, -480, 320, 480);
        snsView_l.frame = CGRectMake(0, -320, 480, 320);
        
        [snsView_p setAlpha:0.0f];
        [snsView_l setAlpha:0.0f];
        
        [UIView commitAnimations];
        
        
    } else {
        [UIView beginAnimations:@"hideStamp" context:nil];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(scmAdAnimationFinished:finished:context:)];
        
        self.view.frame = CGRectMake(0, -530, 480, 530);
        
        [UIView commitAnimations];
        
    }
    
    isNoCampaignView = NO;

}


- (void) createStampView
{    
    self.view.frame = CGRectMake(0, -530, 480, 530);
    [self.view setUserInteractionEnabled:YES];
    
    [self.view addSubview:stampView_p];
    [self.view addSubview:stampView_l];
    
    stampView_p.frame = CGRectMake(0, 0, 320, 530);
    [stampView_p setUserInteractionEnabled:YES];
    
    stampView_l.frame = CGRectMake(0, 160, 480, 370);
    [stampView_l setUserInteractionEnabled:YES];
    
    
    // ---- SNS View and Buttons
    snsView_p.frame = CGRectMake(0, -480, 320, 480);
    [snsView_p setUserInteractionEnabled:YES];
    [snsView_p setAlpha:0.0f];
    fbButton_p.frame = CGRectMake(36, 254, 245, 42);
    twButton_p.frame = CGRectMake(36, 297, 245, 42);
    [fbButton_p addTarget:self action:@selector(scmFacebookLogin) forControlEvents:UIControlEventTouchUpInside];
    [twButton_p addTarget:self action:@selector(scmTwitterLogin) forControlEvents:UIControlEventTouchUpInside];
    [snsView_p addSubview:fbButton_p];
    [snsView_p addSubview:twButton_p];
    
    snsView_l.frame = CGRectMake(0, -160, 480, 320);
    [snsView_l setUserInteractionEnabled:YES];
    [snsView_l setAlpha:0.0f];
    fbButton_l.frame = CGRectMake(124, 162, 245, 42);
    twButton_l.frame = CGRectMake(124, 204, 245, 42);
    [fbButton_l addTarget:self action:@selector(scmFacebookLogin) forControlEvents:UIControlEventTouchUpInside];
    [twButton_l addTarget:self action:@selector(scmTwitterLogin) forControlEvents:UIControlEventTouchUpInside];
    [snsView_l addSubview:fbButton_l];
    [snsView_l addSubview:twButton_l];
    // ---- End of SNS View and Buttons
    
    bannerButton_p.frame = CGRectMake(0, 480, 320, 50);
    bannerButton_l.frame = CGRectMake(0, 320, 480, 50);

    closeArrowButton_p.frame = CGRectMake(82, 432, 156, 48);
    closeArrowButton_l.frame = CGRectMake(158, 272, 156, 48);
    closeXButton_p.frame = CGRectMake(270, 0, 50, 53);
    closeXButton_l.frame = CGRectMake(429, 0, 50, 53);
    
    
    [bannerButton_p addTarget:self action:@selector(showStamp) forControlEvents:UIControlEventTouchUpInside];
    [bannerButton_l addTarget:self action:@selector(showStamp) forControlEvents:UIControlEventTouchUpInside];

    [closeArrowButton_p addTarget:self action:@selector(hideStamp) forControlEvents:UIControlEventTouchUpInside];
    [closeXButton_p addTarget:self action:@selector(hideStamp) forControlEvents:UIControlEventTouchUpInside];
    [closeArrowButton_l addTarget:self action:@selector(hideStamp) forControlEvents:UIControlEventTouchUpInside];
    [closeXButton_l addTarget:self action:@selector(hideStamp) forControlEvents:UIControlEventTouchUpInside];
    
    [stampView_p addSubview:snsView_p];
    [stampView_p addSubview:bannerButton_p];
    [stampView_p addSubview:closeArrowButton_p];
    [stampView_p addSubview:closeXButton_p];
    
    [stampView_l addSubview:snsView_l];
    [stampView_l addSubview:bannerButton_l];
    [stampView_l addSubview:closeArrowButton_l];
    [stampView_l addSubview:closeXButton_l];
    
    [self.view bringSubviewToFront:stampView_l];
    [stampView_l bringSubviewToFront:closeXButton_l];
    
    
    
}

- (void) downloadFiles:(NSArray *)fileArray campaignPath:(NSString *)campaign
{
    // clear cached campaign files
    [self clearCampaignFiles:[NSArray arrayWithObjects:IMG_STAMP_L, IMG_STAMP_P, SCM_AD_XML, nil]];
    
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
        //NSLog(@"SCM - Post to Facebook!");
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
             NSLog(@"Call back!");
             
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
                isTwitterLogin = YES;
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
        [dictXmlInfo writeToFile:SCM_SNS_PLIST atomically:YES];

        [self scmAdPostToTwitter];

    }
}


@end











