//
//  ScmMads.m
//  ScmMads
//
//  Created by jimmy on 8/9/12.
//  Copyright (c) 2012 SecondCommercials. All rights reserved.
//

#import "ScmMads.h"
#import "Utilities.h"

@interface ScmMads ()
{
    UIImageView *stampView_p;   // portrait stamp view
    UIImageView *stampView_l;   // landscape stamp view
    
    UIImageView *snsView_p;     // portrait sns view
    UIImageView *snsView_l;     // landscape sns view
    UIButton *twtButton;
    UIButton *fbButton;
    
    UIButton *bannerButton_p;   // portrait banner button
    UIButton *bannerButton_l;   // landscape banner button
    
    UIButton *closeXButton;
    UIButton *closeArrowButton;
    
    
    // ------------------------
    
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
    
    // Booleans
    BOOL isCountryCodeMatch;
    BOOL isDownloading;
    BOOL isDownloadOk;
    BOOL isInternetAvailable;
    BOOL isNoCampaignView;
    
}

@end

#define SERVER_IP           @"http://211.115.71.69"
#define LOCAL_SERVER_IP     @"http://localhost/"

#define IMG_SNS_CONNECT_P     @"connect_portrait.png"
#define IMG_STAMP_P       @"stamp_portrait.png"
#define IMG_MISSED_P          @"missed_portrait.png"
#define IMG_DEFAULT_P         @"scmdefault_portrait.png"

#define IMG_SNS_CONNECT_L     @"connect_landscape.png"
#define IMG_STAMP_L       @"stamp_landscape.png"
#define IMG_MISSED_L          @"missed_landscape.png"
#define IMG_DEFAULT_L         @"scmdefault_landscape.png"

#define IMG_X_MARK          @"xmark.png"
#define IMG_ARROW           @"arrow.png"

#define SCM_AD_XML          @"scmAdInfo.xml"
#define SCM_AD_PLIST        @"scmAdPlist.plist"
#define SCM_FB_PLIST        @"scmFbPlist.plist"

#define FB_APP_ID           @"196736437067322"

#define PHP_LOGIC_FILE      @"mads_3_1_0.php"


@implementation ScmMads

@synthesize scmMadsDelegate;

- (void) clearDocumentoryFiles
{
    NSArray *campaignFiles = [[NSArray alloc] initWithObjects:IMG_ARROW, IMG_SNS_CONNECT_P, IMG_STAMP_P, IMG_MISSED_P, IMG_X_MARK, SCM_AD_XML, IMG_DEFAULT_P, IMG_SNS_CONNECT_L, IMG_STAMP_L, IMG_MISSED_L, IMG_DEFAULT_L, nil];

    for (int i=0; i<campaignFiles.count; i++) {
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:[campaignFiles objectAtIndex:i]];
        
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
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scmAdPlist.plist"];
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
        NSLog(@"[scm]: Network Response - %@", responseStr);
        
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
        
    } else if ([data length] ==0 && error == nil) {
        NSLog(@"No Data");
    } else if  (error) {
        NSLog(@"Error: %@", error.description);
    }

}

- (id) initScmMads
{
    self=[super init];
    
    // ------------- Initiate Properties ----------
    fileMgr = [[NSFileManager alloc] init];
    phoneCountryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    isCountryCodeMatch  = YES;
    isDownloading       = NO;
    isDownloadOk        = NO;
    isInternetAvailable = NO;
    isNoCampaignView    = NO;

    
    // ------------- Initiate UI ------------------
    
    stampView_p = [[UIImageView alloc]init];
    stampView_l = [[UIImageView alloc]init];

    snsView_p = [[UIImageView alloc]init];
    snsView_l = [[UIImageView alloc]init];
    
    bannerButton_p = [UIButton buttonWithType:UIButtonTypeCustom];
    bannerButton_l = [UIButton buttonWithType:UIButtonTypeCustom];

    closeArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeXButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    twtButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fbButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self createStampView];
    [self syncToServer];
    
    return self;
}

- (void) showScmMads:(NSInteger)points
{
    NSLog(@"[scm]: Show Scm Mads Banner");
    
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
        if (isNoCampaignView == YES) {
            NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0];

            [stampView_p setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_DEFAULT_P]]]];
            [closeArrowButton setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_ARROW]]] forState:UIControlStateNormal];
            [closeXButton setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[docPath stringByAppendingPathComponent:IMG_X_MARK]]] forState:UIControlStateNormal];
        }
    }
    
    [UIImageView beginAnimations:@"showBanner" context:nil];
    [UIImageView setAnimationDuration:0.5f];
    [UIImageView setAnimationDelegate:self];
    
    self.view.frame = CGRectMake(0, -480, 320, 550);
    
    [UIImageView commitAnimations];
}

- (void) hideScmMads
{
    NSLog(@"[scm]: Hide Scm Mads Banner");
    isNoCampaignView = NO;
    
    [UIImageView beginAnimations:@"hideBanner" context:nil];
    [UIImageView setAnimationDuration:0.5f];
    [UIImageView setAnimationDelegate:self];
    
    self.view.frame = CGRectMake(0, -550, 320, 550);
    
    [UIImageView commitAnimations];
}

- (void) showStamp
{
    NSLog(@"[scm]: Show Stamp");
    
    [UIImageView beginAnimations:@"showStamp" context:nil];
    [UIImageView setAnimationDuration:1];
    [UIImageView setAnimationDelegate:self];
    
    self.view.frame = CGRectMake(0, 0, 320, 550);
    
    [UIImageView commitAnimations];
}

- (void) hideStamp
{
    NSLog(@"[scm]: Hide Stamp");
    
    isNoCampaignView = NO;
    
    [UIImageView beginAnimations:@"hideStamp" context:nil];
    [UIImageView setAnimationDuration:1];
    [UIImageView setAnimationDelegate:self];
    
    self.view.frame = CGRectMake(0, -550, 320, 550);
    
    [UIImageView commitAnimations];
}

- (void) createStampView
{
    
    stampView_p.frame = CGRectMake(0, 0, 320, 530);
    //[stampView_p setImage:[UIImage imageNamed:IMG_STAMP_P]];
    [stampView_p setUserInteractionEnabled:YES];
    
    stampView_l.frame = CGRectMake(0, 160, 480, 370);
    //[stampView_l setImage:[UIImage imageNamed:IMG_STAMP_L]];
    [stampView_l setUserInteractionEnabled:YES];
    
    
    bannerButton_p.frame = CGRectMake(0, 480, 320, 50);
    bannerButton_l.frame = CGRectMake(0, 320, 480, 50);

    closeArrowButton.frame = CGRectMake(82, 432, 156, 48);
    closeXButton.frame = CGRectMake(270, 0, 50, 53);
    
    //[closeArrowButton setImage:[UIImage imageNamed:IMG_ARROW] forState:UIControlStateNormal];
    //[closeXButton setImage:[UIImage imageNamed:IMG_X_MARK] forState:UIControlStateNormal];

    [bannerButton_p addTarget:self action:@selector(showStamp) forControlEvents:UIControlEventTouchUpInside];
    [bannerButton_l addTarget:self action:@selector(showStamp) forControlEvents:UIControlEventTouchUpInside];

    [closeArrowButton addTarget:self action:@selector(hideStamp) forControlEvents:UIControlEventTouchUpInside];
    [closeXButton addTarget:self action:@selector(hideStamp) forControlEvents:UIControlEventTouchUpInside];
    
    [stampView_p addSubview:bannerButton_p];
    [stampView_p addSubview:closeArrowButton];
    [stampView_p addSubview:closeXButton];
    
    [stampView_l addSubview:bannerButton_l];
    //[stampView_l addSubview:closeArrowButton];
    //[stampView_l addSubview:closeXButton];
    
    self.view.frame = CGRectMake(0, -530, 320, 530);
    [self.view addSubview:stampView_p];
    [self.view addSubview:stampView_l];
    
    // TODO: check orientation and revive landscape mode
    [stampView_l setHidden:YES];
}

- (void) downloadFiles:(NSArray *)fileArray campaignPath:(NSString *)campaign
{
    
    // Download NoCampaign images if files don't exist in the Documentation Directory.
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        isDownloading = YES;
        for (id fileObject in fileArray) {
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:fileObject];
            
            if ([fileMgr fileExistsAtPath:filePath] == NO) {
                NSLog(@"[scm]: Download ... %@", fileObject);
                
                NSString *strUrl = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@/%@", SERVER_IP,
                                    @"campaign", @"310_campaign", campaign, fileObject];
                NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]];
                [fileData writeToFile:filePath atomically:YES];
            }
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            isDownloading = NO;
            isDownloadOk = YES;
            isInternetAvailable = YES;
        });
    });
}



@end











