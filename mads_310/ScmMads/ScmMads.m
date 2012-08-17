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
    NSArray *downloadFiles;
    //NSError *error;
    NSFileManager *fileMgr;
    
    NSInteger missed_banner_counter;
    NSInteger missed_ad_counter;
    NSString *first_missed_time;
    NSInteger stamp1_banner_counter;
    NSInteger stamp1_ad_counter;
    NSString *first_stamp_time;
    
    // campaign url
    NSString *campaignUrl;
    
    // Country Code
    NSString *phoneCountryCode;
    NSString *campaignCountryCode;
    BOOL isCountryCodeMatch;
    
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
    
    // count stamps
    NSInteger stampsCounter;
    
    // digital voucher YES or NO
    NSString *digitalVoucher;
    
    // hurdle point for a game
    NSInteger hurdlePoint;
}

@end

#define SERVER_IP           @"http://211.115.71.69"
#define LOCAL_SERVER_IP     @"http://localhost/"

#define IMG_SNS_CONNECT_P     @"connect_portrait.png"
#define IMG_STAMP_ONE_P       @"stamp1_portrait.png"
#define IMG_STAMP_TWO_P       @"stamp2_portrait.png"
#define IMG_STAMP_THREE_P     @"stamp3_portrait.png"
#define IMG_MISSED_P          @"missed_portrait.png"
#define IMG_DEFAULT_P         @"scmdefault_portrait.png"

#define IMG_SNS_CONNECT_L     @"connect_landscape.png"
#define IMG_STAMP_ONE_L       @"stamp1_landscape.png"
#define IMG_STAMP_TWO_L       @"stamp2_landscape.png"
#define IMG_STAMP_THREE_L     @"stamp3_landscape.png"
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

@synthesize ScmMadsDelegate;

- (void)clearDocumentoryFiles
{
    
    for (int i=0; i<downloadFiles.count; i++) {
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:[downloadFiles objectAtIndex:i]];
        
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


- (void)parseScmPlistFile
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
        stamp1_banner_counter   = [[dictXmlInfo objectForKey:@"stamp1_banner_imp"] intValue];
        stamp1_ad_counter       = [[dictXmlInfo objectForKey:@"stamp1_banner_click"] intValue];
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
        stampsCounter = 0;
        hurdlePoint = 0;
        digitalVoucher = @"NO";
        campaignName = @"NoCampaign";
        
        missed_banner_counter   = 0;
        missed_ad_counter       = 0;
        stamp1_banner_counter   = 0;
        stamp1_ad_counter       = 0;
        
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
    NSString* appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* deviceId = [[UIDevice currentDevice] uniqueIdentifier];
    
    NSString *baseUrl = @"http://211.115.71.69/logic/tmp.php";
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
    params = [params stringByAppendingFormat:@"&stamp1_banner_imp=%@", [NSNumber numberWithInteger:stamp1_banner_counter]];
    params = [params stringByAppendingFormat:@"&stamp1_banner_click=%@", [NSNumber numberWithInteger:stamp1_ad_counter]];
    params = [params stringByAppendingFormat:@"&first_stamp_time=%@", first_stamp_time];

    
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
    if ([data length] > 0 && error == nil)
    {
        NSLog(@"Data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    } else if ([data length] ==0 && error == nil) {
        NSLog(@"No Data");
    } else if  (error) {
        NSLog(@"Error: %@", error.description);
    }

}

-(id)initScmMads
{
    self=[super init];
    
    // ------------- Initiate Properties ----------
    fileMgr = [[NSFileManager alloc] init];
    
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

-(void)showScmMads:(NSInteger)points
{
    
    [UIImageView beginAnimations:@"showBanner" context:nil];
    [UIImageView setAnimationDuration:0.5f];
    [UIImageView setAnimationDelegate:self];
    
    self.view.frame = CGRectMake(0, -480, 320, 550);
    
    [UIImageView commitAnimations];
}

-(void)hidenScmMads
{
    [UIImageView beginAnimations:@"hideBanner" context:nil];
    [UIImageView setAnimationDuration:0.5f];
    [UIImageView setAnimationDelegate:self];
    
    self.view.frame = CGRectMake(0, -550, 320, 550);
    
    [UIImageView commitAnimations];
}

-(void)showStamp
{
    NSLog(@"Show Stamp");
    
    [UIImageView beginAnimations:@"showStamp" context:nil];
    [UIImageView setAnimationDuration:1];
    [UIImageView setAnimationDelegate:self];
    
    self.view.frame = CGRectMake(0, 0, 320, 550);
    
    [UIImageView commitAnimations];
}

-(void)hideStamp
{
    NSLog(@"Hide Stamp");
    
    [UIImageView beginAnimations:@"hideStamp" context:nil];
    [UIImageView setAnimationDuration:1];
    [UIImageView setAnimationDelegate:self];
    
    self.view.frame = CGRectMake(0, -550, 320, 550);
    
    [UIImageView commitAnimations];
}

-(void)createStampView
{
    
    stampView_p.frame = CGRectMake(0, 0, 320, 530);
    [stampView_p setImage:[UIImage imageNamed:@"stamp1_portrait.png"]];
    [stampView_p setUserInteractionEnabled:YES];
    
    stampView_l.frame = CGRectMake(0, 160, 480, 370);
    [stampView_l setImage:[UIImage imageNamed:@"stamp1.png"]];
    [stampView_l setUserInteractionEnabled:YES];
    
    
    bannerButton_p.frame = CGRectMake(0, 480, 320, 50);
    bannerButton_l.frame = CGRectMake(0, 320, 480, 50);

    closeArrowButton.frame = CGRectMake(82, 432, 156, 48);
    closeXButton.frame = CGRectMake(270, 0, 50, 53);
    
    [closeArrowButton setImage:[UIImage imageNamed:@"arrow.png"] forState:UIControlStateNormal];
    [closeXButton setImage:[UIImage imageNamed:@"xmark.png"] forState:UIControlStateNormal];

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



@end











