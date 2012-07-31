//
//  SecondCommercialsAd.m
//  SecondCommercialsAd
//
//  Created by Yongmo Liang on 11/4/11.
//  Copyright (c) 2011 SecondCommercials. All rights reserved.
//

#import "SecondCommercialsAd.h"
#import "TwitterHandler.h"
#import <FacebookSDK/FacebookSDK.h>
#import <SecondCommercialsAd/ASIHTTPRequest.h>
#import <SecondCommercialsAd/ASIFormDataRequest.h>


@interface SecondCommercialsAd() <FBLoginViewDelegate, ASIHTTPRequestDelegate>{
    
    
    // scmAdBgButton - receive any event from upper layer
    UIButton *scmAdBgButton;
    
    // scmAdStempView- show stemp view
    UIButton *scmAdStampView;
    
    // TWO close button
    UIButton *scmAdCloseArrow;
    UIButton *scmAdCloseX;
    
    // SNS login view
    UIImageView *scmAdSnsLoginView;
    
    // Facebook Button
    UIButton *scmAdFacebookButton;
    
    // Twitter Button
    UIButton *scmAdTwitterButton;
    
    
    
    // hurdle text
    UILabel *scmAdHurdleLabel;
    
    // bannerPosition - banner position
    BannerPosition bannerPosition;
    
    // NSXMLParser parsing xml file from server & supplementary vars
    NSXMLParser *xmlParser;
    NSString *currentElement;
    
    // NSDictionary to hold XML information
    NSMutableDictionary *dictXmlInfo;
    
    // count stamps
    NSInteger stampsCounter;
    
    // digital voucher YES or NO
    NSString *digitalVoucher;
    
    // hurdle point for a game
    NSInteger hurdlePoint;
    
    // Facebook Handler
    FBSession *fbSession;
    
    
    // Twitter Handler
    TWTweetComposeViewController *twController;
    TWRequest *twRequest;
    ACAccountStore *accountStore;
    ACAccount *twAccount;
    
    TwitterHandler *twHandler;
    
    BOOL isDownloadOk;
    
    
    /************************************************************/
    
    
    // campaign name
    NSString *campaignName;
    
    /**** Globals ****/
    NSArray *downloadFiles;
    //NSError *error;
    NSFileManager *fileMgr;
    NSMutableDictionary *xmlContainer;
    NSMutableDictionary *fbContainer;
    NSMutableDictionary *twContainer;
    
    NSString *fb_email;
    NSString *fb_name;
    
    NSString *tw_username;
    
    UIAlertView *alert_dv_fb;
    UIAlertView *alert_dv_tw;
    
    // 8 stamps expose status
    NSInteger missed_banner_counter;
    NSInteger missed_ad_counter;
    NSString *first_missed_time;
    NSInteger stamp1_banner_counter;
    NSInteger stamp1_ad_counter;
    NSString *first_stamp_time;
    NSInteger stamp2_banner_counter;
    NSInteger stamp2_ad_counter;
    NSString *second_stamp_time;
    NSInteger stamp3_banner_counter;
    NSInteger stamp3_ad_counter;
    NSString *third_stamp_time;
    
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
    
    
    // bools
    BOOL isMissedView;
    BOOL isSnsLoginView;
    BOOL isNoCampaignView;
    BOOL isInternetAvailable;
    BOOL isDownloading;
    
    BOOL isFacebookLogin, isTwitterLogin;
    
    BOOL isPortraitMode;
    

}

- (void) scmAdBannerCallback: (id)sender;

@end


@implementation SecondCommercialsAd

@synthesize scmAdView;
@synthesize scmAdDelegate;




/**** MACROS ****/
#define SERVER_IP           @"http://211.115.71.69"

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

#define PHP_LOGIC_FILE      @"mads_3_0_2.php" 


#define TW_OAUTH_CONSUMER_KEY @"W0fCYSB0zUTlRqfaVqaXOA"	//TODO: Add your consumer key here
#define TW_OAUTH_CONSUMER_SECRET @"MRSfLUfzicBLrLn1v87RmwsISFGSWnqslDdKkmgBJU"	//TODO: add your consumer secret here.



- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSString *)getCurrentDateTime
{
    NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    [dataFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    
    NSString *dateString = [dataFormatter stringFromDate:tmpDate];
    return dateString;
}

- (void)parseScmAdXmlFile: (NSData *)fileData
{
    xmlParser = [[NSXMLParser alloc] initWithData:fileData];
    [xmlParser setDelegate:self];
    [xmlParser setShouldProcessNamespaces:NO];
    [xmlParser setShouldReportNamespacePrefixes:NO];
    [xmlParser setShouldResolveExternalEntities:NO];
    [xmlParser parse];
}

- (void)parseScmPlistFile
{
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
    if ([fileMgr fileExistsAtPath:filePath]) {
        dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        stampsCounter = [[dictXmlInfo objectForKey:@"stamps"] intValue];
        campaignName = [dictXmlInfo objectForKey:@"campaign"];
        digitalVoucher = [dictXmlInfo objectForKey:@"digitalVoucher"];
        hurdlePoint = [[dictXmlInfo objectForKey:@"hurdle"] intValue];;

        missed_banner_counter   = [[dictXmlInfo objectForKey:@"missed_banner_imp"] intValue];
        missed_ad_counter       = [[dictXmlInfo objectForKey:@"missed_banner_click"] intValue];
        first_missed_time       = [dictXmlInfo objectForKey:@"first_missed_time"];
        stamp1_banner_counter   = [[dictXmlInfo objectForKey:@"stamp1_banner_imp"] intValue];
        stamp1_ad_counter       = [[dictXmlInfo objectForKey:@"stamp1_banner_click"] intValue];
        first_stamp_time        = [dictXmlInfo objectForKey:@"first_stamp_time"];
        stamp2_banner_counter   = [[dictXmlInfo objectForKey:@"stamp2_banner_imp"] intValue];
        stamp2_ad_counter       = [[dictXmlInfo objectForKey:@"stamp2_banner_click"] intValue];
        second_stamp_time        = [dictXmlInfo objectForKey:@"second_stamp_time"];
        stamp3_banner_counter   = [[dictXmlInfo objectForKey:@"stamp3_banner_imp"] intValue];
        stamp3_ad_counter       = [[dictXmlInfo objectForKey:@"stamp3_banner_click"] intValue];
        third_stamp_time        = [dictXmlInfo objectForKey:@"third_stamp_time"];

        
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
        
        
        //NSLog(@"hurdle x:%d, y:%d, w:%d, h:%d", hurdle_x, hurdle_y, hurdle_w, hurdle_h);

        
        
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
        stamp2_banner_counter   = 0;
        stamp2_ad_counter       = 0;
        stamp3_banner_counter   = 0;
        stamp3_ad_counter       = 0;
        
        first_missed_time   = @"0000-00-00 00:00:00";
        first_stamp_time    = @"0000-00-00 00:00:00";
        second_stamp_time   = @"0000-00-00 00:00:00";
        third_stamp_time    = @"0000-00-00 00:00:00";
        
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

- (void)clearDocumentoryFiles
{
    
    for (int i=0; i<downloadFiles.count; i++) {
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:[downloadFiles objectAtIndex:i]];        
        
        if ([fileMgr fileExistsAtPath:filePath]) {
            if ([fileMgr removeItemAtPath:filePath error:nil]!=YES) {
                //NSLog(@"Unable to delete file: %@", [error localizedDescription]);
                //NSLog(@"Unable to delete file!");
            }
        }
    }
    
    // Remove PLIST too
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
    if ([fileMgr fileExistsAtPath:filePath]) {
        if ([fileMgr removeItemAtPath:filePath error:nil]!=YES) {
            //NSLog(@"Unable to delete file: %@", [error localizedDescription]);
            //NSLog(@"Unable to delete file!");
        }
    }
}


- (BOOL)scmAdSyncToServer
{    
    //NSLog(@"Sync to Server");
    [self parseScmPlistFile];
    
    NSString* appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* deviceId = [[UIDevice currentDevice] uniqueIdentifier];
    NSString* phpFile = [[NSString alloc] initWithFormat:@"%@/logic/%@", SERVER_IP, PHP_LOGIC_FILE];
    NSURL *url = [NSURL URLWithString:phpFile];
        
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setPostValue:@"M.AD.S" forKey:@"id"];
    [request setPostValue:@"qkrtkdwls78!" forKey:@"passwd"];
    [request setPostValue:deviceId forKey:@"DeviceID"];
    [request setPostValue:appId forKey:@"AppID"];
    [request setPostValue:[NSNumber numberWithInteger:stampsCounter] forKey:@"stampsCounter"];
    [request setPostValue:campaignName forKey:@"campaignName"];
    [request setPostValue:digitalVoucher forKey:@"digitalVoucher"];
    [request setPostValue:[NSNumber numberWithInteger:hurdlePoint] forKey:@"hurdle"];
    [request setPostValue:phoneCountryCode forKey:@"CountryCode"];
    
    [request setPostValue:[NSNumber numberWithInteger:missed_banner_counter] forKey:@"missed_banner_imp"];
    [request setPostValue:[NSNumber numberWithInteger:missed_ad_counter] forKey:@"missed_banner_click"];
    [request setPostValue:first_missed_time forKey:@"first_missed_time"];
    [request setPostValue:[NSNumber numberWithInteger:stamp1_banner_counter] forKey:@"stamp1_banner_imp"];
    [request setPostValue:[NSNumber numberWithInteger:stamp1_ad_counter] forKey:@"stamp1_banner_click"];
    [request setPostValue:first_stamp_time forKey:@"first_stamp_time"];
    [request setPostValue:[NSNumber numberWithInteger:stamp2_banner_counter] forKey:@"stamp2_banner_imp"];
    [request setPostValue:[NSNumber numberWithInteger:stamp2_ad_counter] forKey:@"stamp2_banner_click"];
    [request setPostValue:second_stamp_time forKey:@"second_stamp_time"];
    [request setPostValue:[NSNumber numberWithInteger:stamp3_banner_counter] forKey:@"stamp3_banner_imp"];
    [request setPostValue:[NSNumber numberWithInteger:stamp3_ad_counter] forKey:@"stamp3_banner_click"];
    [request setPostValue:third_stamp_time forKey:@"third_stamp_time"];

    
    
    [request setTimeOutSeconds:2.0f];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *responseString = [[request responseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //NSLog(@"response: ---- %@", responseString);

        //NSData *responseData = [request responseData];
        
        if ([responseString isEqualToString:@"NoCampaign"]) {
            NSLog(@"[scm]: campaign name - NoCampaign");
            isNoCampaignView = YES;
            
            NSString *filePathDefault;
            if (isPortraitMode == YES) {
                filePathDefault = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:IMG_DEFAULT_P];
            } else {
                filePathDefault = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:IMG_DEFAULT_L];
            }
            
            NSString *filePathXml = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_XML];
            NSString *filePathArrow = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:IMG_ARROW];
            NSString *filePathX = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:IMG_X_MARK];
            

                if (![fileMgr fileExistsAtPath:filePathDefault] || ![fileMgr fileExistsAtPath:filePathXml] ||
                    ![fileMgr fileExistsAtPath:filePathArrow] || ![fileMgr fileExistsAtPath:filePathX]) {
                    
                    //NSLog(@"don't have SCM AD files - download!!");
                    
                    isDownloading = YES;
                    
                    NSString *strUrl;
                    if (isPortraitMode == YES) {
                        strUrl = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@", SERVER_IP, 
                                            @"campaign", @"NoCampaign", IMG_DEFAULT_P];
                        NSLog(@"[scm]: Download :......... %@", IMG_DEFAULT_P);
                    } else {
                        strUrl = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@", SERVER_IP, 
                                  @"campaign", @"NoCampaign", IMG_DEFAULT_L];
                        NSLog(@"[scm]: Download :......... %@", IMG_DEFAULT_L);
                    }
                    
                    
                    NSURL *fileUrl = [NSURL URLWithString:strUrl];
                    NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];
                    NSString *filePath;
                    
                    if (isPortraitMode == YES) {
                        filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:IMG_DEFAULT_P];
                    } else {
                        filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:IMG_DEFAULT_L];
                    }
                    
                    [fileData writeToFile:filePath atomically:YES];
                    
                    NSString *strUrl2 = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@", SERVER_IP, 
                                         @"campaign", @"NoCampaign", SCM_AD_XML];
                    NSLog(@"[scm]: Download :......... %@", SCM_AD_XML);
                    NSURL *fileUrl2 = [NSURL URLWithString:strUrl2];
                    NSData *fileData2 = [NSData dataWithContentsOfURL:fileUrl2];
                    NSString *filePath2 = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_XML];
                    [fileData2 writeToFile:filePath2 atomically:YES];
                    
                    NSString *strUrl3 = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@", SERVER_IP, 
                                         @"campaign", @"NoCampaign", IMG_ARROW];
                    NSLog(@"[scm]: Download :......... %@", IMG_ARROW);
                    NSURL *fileUrl3 = [NSURL URLWithString:strUrl3];
                    NSData *fileData3 = [NSData dataWithContentsOfURL:fileUrl3];
                    NSString *filePath3 = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:IMG_ARROW];
                    [fileData3 writeToFile:filePath3 atomically:YES];
                    
                    NSString *strUrl4 = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@", SERVER_IP, 
                                         @"campaign", @"NoCampaign", IMG_X_MARK];
                    NSLog(@"[scm]: Download :......... %@", IMG_X_MARK);
                    NSURL *fileUrl4 = [NSURL URLWithString:strUrl4];
                    NSData *fileData4 = [NSData dataWithContentsOfURL:fileUrl4];
                    NSString *filePath4 = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:IMG_X_MARK];
                    [fileData4 writeToFile:filePath4 atomically:YES];
                    
                    // Parse XML File
                    if ([fileMgr fileExistsAtPath:filePath2]) {
                        [self parseScmAdXmlFile:fileData2];
                    }
                }
                
                isDownloading = NO;
                isDownloadOk = YES;

                
            
        } else if ([responseString isEqualToString:@"Same Campaign"]) {
            NSLog(@"[scm]: Same Campaign");
            isDownloadOk = YES;

        } else if ([[responseString substringToIndex:6] isEqualToString:@"Hurdle"]) {
            NSLog(@"[scm]: Hurdle Changed");
            isDownloadOk = YES;
        
            hurdlePoint = [[responseString substringFromIndex:6] intValue];
            
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
            dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath]; 
            // save missed_banner_imp to plist file
            [dictXmlInfo setObject:[[NSString alloc] initWithFormat:@"%d", hurdlePoint] forKey:@"hurdle"];
            
            [dictXmlInfo writeToFile:filePath atomically:YES];
            dictXmlInfo = nil;
        } else if ([responseString isEqualToString:@"NoCountryCodeMatch"]) {
            isCountryCodeMatch = NO;
        } else {
            NSLog(@"[scm]: - Campaign: ************************** %@", responseString);

            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // Add code here to do background processing
                //
                //
                isDownloading = YES;
                for (id fileObject in downloadFiles) {
                    NSString *strUrl = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@", SERVER_IP, 
                                        @"campaign", responseString, fileObject];
                    NSLog(@"[scm]: Download :......... %@", fileObject);
                    NSURL *fileUrl = [NSURL URLWithString:strUrl];
                    NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];
                    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:fileObject];
                    [fileData writeToFile:filePath atomically:YES];
                    
                    // Parse XML File
                    if ([fileMgr fileExistsAtPath:filePath] && [fileObject isEqualToString:SCM_AD_XML]) {
                        [self parseScmAdXmlFile:fileData];
                    }
                    
                }
                dispatch_async( dispatch_get_main_queue(), ^{
                    // Add code here to update the UI/send notifications based on the
                    // results of the background processing
                    isDownloading = NO;
                    isDownloadOk = YES;
                });
            });
            
        }
        isInternetAvailable = YES;
    } else {
        NSLog(@"[scm]: - Network Faield with %@", error);
        isDownloadOk = YES;
        isInternetAvailable = NO;

    };
            
    return YES;
}


- (void) scmAdBannerCallback: (id)sender
{
    [UIView beginAnimations:@"showStampView" context:(void *)scmAdView];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(scmAdAnimationFinished:finished:context:)];
    
    
    if (isPortraitMode == YES) {
        scmAdView.frame = CGRectMake(0, 0, 320, 550);
    } else {
        scmAdView.frame = CGRectMake(0, 0, 480, 370);
    }

    // call delegate mathod
    [[self scmAdDelegate] scmAdViewWillShow];
    
    // disable button event feature
    [scmAdStampView setUserInteractionEnabled:NO];
    
    [UIView commitAnimations];

}

- (void) scmAdCloseStampView: (id)sender
{
    
    
    if (isSnsLoginView == YES) {
        [UIView beginAnimations:@"HideSnsLoginView" context:(void *)scmAdView];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationDelegate:self];
        
        isSnsLoginView = NO;
        if (bannerPosition == BOTTOM) {
            scmAdSnsLoginView.frame = CGRectMake(0, 480, 320, 480);
        } else {
            if (isPortraitMode == YES) {
                scmAdSnsLoginView.frame = CGRectMake(0, -480, 320, 480);
            } else {
                scmAdSnsLoginView.frame = CGRectMake(0, -320, 480, 320);
            }
        }
        [scmAdSnsLoginView setAlpha:0.0f];
        [UIView commitAnimations]; 

        
    } else {
        [UIView beginAnimations:@"closeStampView" context:(void *)scmAdView];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(scmAdAnimationFinished:finished:context:)];
        
        if (bannerPosition == BOTTOM) {
            scmAdView.frame = CGRectMake(0, 480, 320, 550);
        } else {
            if (isPortraitMode == YES) {
                scmAdView.frame = CGRectMake(0, -550, 320, 550);
            } else {
                scmAdView.frame = CGRectMake(0, -370, 480, 370);
            }
        }
        
        [UIView commitAnimations];
        
        // enable butotn event feature
        [scmAdStampView setUserInteractionEnabled:YES];
    }
    isNoCampaignView = NO;
    
}


- (void)viewPositioningWithModePortrait
{
    
    if (scmAdView) {
        [scmAdView release];
    }
    // initiate container view
    if (bannerPosition == BOTTOM) {
        scmAdView = [[UIView alloc] initWithFrame:CGRectMake(0, 480, 320, 550)];
    } else {
        scmAdView = [[UIView alloc] initWithFrame:CGRectMake(0, -550, 320, 550)];
    }
    
    [scmAdView addSubview:scmAdBgButton];
    [scmAdView addSubview:scmAdStampView];
    [scmAdView addSubview:scmAdSnsLoginView];
    [scmAdView addSubview:scmAdCloseArrow];
    [scmAdView addSubview:scmAdCloseX];
    
    scmAdBgButton.frame = CGRectMake(0, 0, 320, 550);
    scmAdStampView.frame = CGRectMake(0, 0, 320, 550);
    if (bannerPosition == BOTTOM) 
        scmAdSnsLoginView.frame = CGRectMake(0, 480, 320, 550);
    else 
        scmAdSnsLoginView.frame = CGRectMake(0, -550, 320, 550);
    scmAdCloseArrow.frame = CGRectMake(82, 432, 156, 48);
    scmAdCloseX.frame = CGRectMake(270, 0, 50, 53);
    
    [scmAdSnsLoginView addSubview:scmAdFacebookButton];
    [scmAdSnsLoginView addSubview:scmAdTwitterButton];
    scmAdFacebookButton.frame = CGRectMake(36, 254, 245, 42);
    scmAdTwitterButton.frame = CGRectMake(36, 297, 245, 42);
    
    // Hurdle Label
    /*
    scmAdHurdleLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(30, 350, 260, 20)];
    scmAdHurdleLabel.textAlignment =  UITextAlignmentCenter;
    scmAdHurdleLabel.textColor = [UIColor whiteColor];
    scmAdHurdleLabel.backgroundColor = [UIColor clearColor];
    */
    [scmAdStampView addSubview:scmAdHurdleLabel];
    
}

- (void)viewPositioningWithModeLandScape
{
    if (scmAdView) {
        [scmAdView release];
    }
    
    scmAdView = [[UIView alloc] initWithFrame:CGRectMake(0, -370, 480, 370)];
    
    [scmAdView addSubview:scmAdBgButton];
    [scmAdView addSubview:scmAdStampView];
    [scmAdView addSubview:scmAdSnsLoginView];
    [scmAdView addSubview:scmAdCloseArrow];
    [scmAdView addSubview:scmAdCloseX];

    scmAdBgButton.frame = CGRectMake(0, 0, 480, 370);
    scmAdStampView.frame = CGRectMake(0, 0, 480, 370);
    
    scmAdSnsLoginView.frame = CGRectMake(0, -370, 480, 370);
    scmAdCloseArrow.frame = CGRectMake(158, 272, 156, 48);
    
    // TMP for debugging
    
    //scmAdCloseX = [UIButton buttonWithType:UIButtonTypeCustom];
    //[scmAdCloseX setUserInteractionEnabled:YES];
    //[scmAdCloseX addTarget:self action:@selector(scmAdCloseStampView:) forControlEvents:UIControlEventTouchUpInside];
    
    scmAdCloseX.frame = CGRectMake(429, 0, 50, 53);
    //scmAdCloseX.frame = CGRectMake(400, 0, 50, 53);

    
    [scmAdSnsLoginView addSubview:scmAdFacebookButton];
    [scmAdSnsLoginView addSubview:scmAdTwitterButton];    
    
    
    scmAdFacebookButton.frame = CGRectMake(124, 162, 245, 42);
    scmAdTwitterButton.frame = CGRectMake(124, 204, 245, 42);
    // Hurdle Label
    /*
    scmAdHurdleLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(108, 240, 264, 20)];
    scmAdHurdleLabel.textAlignment =  UITextAlignmentCenter;
    scmAdHurdleLabel.textColor = [UIColor whiteColor];
    scmAdHurdleLabel.backgroundColor = [UIColor clearColor];
    */
    [scmAdStampView addSubview:scmAdHurdleLabel];
}

- (void) scmShowAdBannerView : (NSInteger)point
{    
    
    
    if (isCountryCodeMatch == NO) {
        NSLog(@"[scm]: Country Code doesn't match");
        return;
    }
        
    [[self scmAdDelegate] scmAdBannerWillShow];
    
    // sync to server before showing stamps
    if (isDownloading == NO) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIDeviceOrientationPortrait) {
            NSLog(@"[scm]: Device has Portrait Mode...");
            isPortraitMode = YES;
        } else  {
            NSLog(@"[scm]: Device has Landscape Mode...");
            isPortraitMode = NO;
        }
        
        // adjust position based on orientation
        if (isPortraitMode == YES) {
            [self viewPositioningWithModePortrait];
        } else {
            [self viewPositioningWithModeLandScape];
        }
        
        self.view = scmAdView;
        
        [self scmAdSyncToServer];
    }
    
    if (isDownloadOk == YES) {
        
        // No matter missed or get chance, We will show sns view!
        
      
         
        
        NSString *filePathSns;
        if (isPortraitMode == YES) {
            filePathSns = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] 
                           stringByAppendingPathComponent:IMG_SNS_CONNECT_P];
        } else {
            filePathSns = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] 
                           stringByAppendingPathComponent:IMG_SNS_CONNECT_L];
        }
        
        
        if ([fileMgr fileExistsAtPath:filePathSns]) {
            UIImage *imageSns = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePathSns]];
            [scmAdSnsLoginView setImage:imageSns];
            scmAdSnsLoginView.opaque = YES;
        }
        
        
        NSString *imgStr;
        
        //if ([self.campaignName isEqualToString:@"NoCampaign"]) {
        if (isNoCampaignView == YES) {
            if (isPortraitMode == YES) {
                imgStr = IMG_DEFAULT_P;
            } else {
                imgStr = IMG_DEFAULT_L;
            }
        } else if (hurdlePoint > point) {
            isMissedView = YES;
            
            if (isPortraitMode == YES) {
                imgStr = IMG_MISSED_P;

            } else {
                imgStr = IMG_MISSED_L;
            }
            
            // Save stampsCounter to Plist file
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
            if ([fileMgr fileExistsAtPath:filePath]) {
                dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath]; 
                // save missed_banner_imp to plist file
                [dictXmlInfo setObject:[[NSString alloc] initWithFormat:@"%d", ++missed_banner_counter] forKey:@"missed_banner_imp"];
                
                [dictXmlInfo writeToFile:filePath atomically:YES];
                dictXmlInfo = nil;
                //[dictXmlInfo release];
                
            }
        } else if (stampsCounter < 3) {
            stampsCounter++;
            
            // Save stampsCounter to Plist file
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
            if ([fileMgr fileExistsAtPath:filePath]) {
                dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
                
                // save stampx_banner_imp to plist file
                if (stampsCounter == 1)
                    [dictXmlInfo setObject:[[NSString alloc] initWithFormat:@"%d", ++stamp1_banner_counter] forKey:@"stamp1_banner_imp"];  
                else if (stampsCounter == 2)
                    [dictXmlInfo setObject:[[NSString alloc] initWithFormat:@"%d", ++stamp2_banner_counter] forKey:@"stamp2_banner_imp"];  
                else if (stampsCounter == 3)
                    [dictXmlInfo setObject:[[NSString alloc] initWithFormat:@"%d", ++stamp3_banner_counter] forKey:@"stamp3_banner_imp"];  
                
                [dictXmlInfo writeToFile:filePath atomically:YES];
                dictXmlInfo = nil;
                //[dictXmlInfo release];
            }
            
            if (stampsCounter == 1) {
                if (isPortraitMode == YES) {
                    imgStr = IMG_STAMP_ONE_P;
                } else {
                    imgStr = IMG_STAMP_ONE_L;
                }
            } else if (stampsCounter == 2) {
                if (isPortraitMode == YES) {
                    imgStr = IMG_STAMP_TWO_P;
                } else {
                    imgStr = IMG_STAMP_TWO_L;
                }
            } else if (stampsCounter == 3) { 
                if (isPortraitMode == YES) {
                    imgStr = IMG_STAMP_THREE_P;
                } else {
                    imgStr = IMG_STAMP_THREE_L;
                }
            }
        } else {
            //NSLog(@"Something is wrong!!!");
            if (isPortraitMode == YES) {
                imgStr = IMG_DEFAULT_P;
            } else {
                imgStr = IMG_DEFAULT_L;
            }
        }
        
        NSString *filePathBack = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:imgStr];
        if ([fileMgr fileExistsAtPath:filePathBack]) {
            UIImage *imageBack = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePathBack]];
            [scmAdStampView setImage:imageBack forState:UIControlStateNormal];
            scmAdStampView.opaque = YES;
        }
        
        NSString *filePathArrow = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:IMG_ARROW];
        if ([fileMgr fileExistsAtPath:filePathArrow]) {
            UIImage *imageArrow = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePathArrow]];
            [scmAdCloseArrow setImage:imageArrow forState:UIControlStateNormal];
            scmAdCloseArrow.opaque = YES;
        }
        
        NSString *filePathX = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:IMG_X_MARK];
        if ([fileMgr fileExistsAtPath:filePathX]) {
            UIImage *imageX = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePathX]];
            [scmAdCloseX setImage:imageX forState:UIControlStateNormal];
            scmAdCloseX.opaque = YES;
        }
        
        if (isNoCampaignView == YES) {
            scmAdHurdleLabel.hidden = YES;
        } else {
            scmAdHurdleLabel.hidden = NO;
            if (isPortraitMode == YES) {
                scmAdHurdleLabel.frame = CGRectMake(hurdle_x_p, hurdle_y_p, hurdle_w_p, hurdle_h_p);
            } else {
                scmAdHurdleLabel.frame = CGRectMake(hurdle_x_l, hurdle_y_l, hurdle_w_l, hurdle_h_l);

            }
            scmAdHurdleLabel.text = [NSString stringWithFormat: @"Hurdle Score: %d", hurdlePoint];
        }
        
        
        [UIView beginAnimations:@"ShowBannerView" context:(void *)scmAdView];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationDelegate:self];
        
        
        
        if (isPortraitMode == YES) {
            if (bannerPosition == BOTTOM) {
                scmAdView.frame = CGRectMake(0, 410, 320, 550);
                [UIView commitAnimations];   
            } else {
            
                [UIView animateWithDuration:1.0 animations:^{ scmAdView.frame = CGRectMake(0, -470, 320, 550); } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.2 animations:^{ scmAdView.frame = CGRectMake (0, -480, 320, 550); } completion:^(BOOL finished) {
                        /*NSLog(@"Animation Finished");*/}];
                }];
                
                /* Original
                scmAdView.frame = CGRectMake(0, -480, 320, 550);
                [UIView commitAnimations];
                */
            }
        } else {
            
            [UIView animateWithDuration:0.5 animations:^{ scmAdView.frame = CGRectMake(0, -310, 480, 370); } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{ scmAdView.frame = CGRectMake (0, -320, 480, 370); } completion:^(BOOL finished) {
                    /*NSLog(@"Animation Finished");*/}];
            }];
            [UIView commitAnimations];

            
            /* Origianl
            scmAdView.frame = CGRectMake(0, -320, 480, 370);
            [UIView commitAnimations];
            */
        }
        
        isDownloadOk = NO;
    }
}


- (void)scmHideAdBannerView
{
    [UIView beginAnimations:@"ShowBannerView" context:(void *)scmAdView];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationDelegate:self];
    

    if (bannerPosition == BOTTOM) {
        scmAdView.frame = CGRectMake(0, 480, 320, 550);
        [UIView commitAnimations];   
    } else {
        
        if (isPortraitMode == YES) {
            scmAdView.frame = CGRectMake(0, -550, 320, 550);
        } else {
            scmAdView.frame = CGRectMake(0, -370, 480, 370);
        }
        [UIView commitAnimations]; 
    }
    isDownloadOk = NO;
    isMissedView = NO;
}


- (id)initWithPosition:(BannerPosition)position
{
    
    phoneCountryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    NSLog(@"[scm]: Phone Country Code: %@", phoneCountryCode);
    
    bannerPosition = position;
    hurdlePoint = 0;
    
    // initiate file manager
    fileMgr = [NSFileManager defaultManager];
    
    
    
    // initiate container view scmAdView
    scmAdView = [[UIView alloc] initWithFrame:CGRectZero];
    scmAdView.opaque = YES;
    
    // initiate event receiver scmAdBgButton
    scmAdBgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scmAdBgButton setUserInteractionEnabled:YES];
    
    // initiate ad view
    scmAdStampView = [UIButton buttonWithType:UIButtonTypeCustom];
    [scmAdStampView setUserInteractionEnabled:YES];
    [scmAdStampView addTarget:self action:@selector(scmAdBannerCallback:) forControlEvents:UIControlEventTouchUpInside];
    
    // initiate close buttons
    scmAdCloseArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    [scmAdCloseArrow setUserInteractionEnabled:YES];
    [scmAdCloseArrow addTarget:self action:@selector(scmAdCloseStampView:) forControlEvents:UIControlEventTouchUpInside];
    
    scmAdCloseX = [UIButton buttonWithType:UIButtonTypeCustom];
    [scmAdCloseX setUserInteractionEnabled:YES];
    [scmAdCloseX addTarget:self action:@selector(scmAdCloseStampView:) forControlEvents:UIControlEventTouchUpInside];
    
    scmAdSnsLoginView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [scmAdSnsLoginView setUserInteractionEnabled:YES];
    [scmAdSnsLoginView setAlpha:0.0f];

    
    scmAdFacebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scmAdFacebookButton setUserInteractionEnabled:YES];
    [scmAdFacebookButton addTarget:self action:@selector(scmAdFacebookLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    scmAdTwitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scmAdTwitterButton setUserInteractionEnabled:YES];
    [scmAdTwitterButton addTarget:self action:@selector(scmAdTwitterLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    scmAdHurdleLabel = [ [UILabel alloc ] initWithFrame:CGRectZero];
    scmAdHurdleLabel.textAlignment =  UITextAlignmentCenter;
    scmAdHurdleLabel.textColor = [UIColor whiteColor];
    scmAdHurdleLabel.backgroundColor = [UIColor clearColor];
    
    /*
    if (isPortraitMode == YES) {
        [self viewPositioningWithModePortrait];
    } else {
        [self viewPositioningWithModeLandScape];
    }
     */
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIDeviceOrientationPortrait) {
        NSLog(@"[scm]: Device has Portrait Mode...");
        isPortraitMode = YES;
    } else  {
        NSLog(@"[scm]: Device has Landscape Mode...");
        isPortraitMode = NO;
    }
    
    
    // To support dynamic orientation we download all of files to device 
    // TODO: this is not optimal solution for it. 
    if (isPortraitMode == YES) {
        downloadFiles = [[NSArray alloc] initWithObjects:IMG_ARROW, IMG_SNS_CONNECT_P, IMG_STAMP_ONE_P, IMG_STAMP_TWO_P, IMG_STAMP_THREE_P, IMG_MISSED_P, IMG_X_MARK, SCM_AD_XML, IMG_DEFAULT_P, IMG_SNS_CONNECT_L, IMG_STAMP_ONE_L, IMG_STAMP_TWO_L, IMG_STAMP_THREE_L, IMG_MISSED_L, IMG_DEFAULT_L, nil];
    } else {
        downloadFiles = [[NSArray alloc] initWithObjects:IMG_ARROW, IMG_SNS_CONNECT_P, IMG_STAMP_ONE_P, IMG_STAMP_TWO_P, IMG_STAMP_THREE_P, IMG_MISSED_P, IMG_X_MARK, SCM_AD_XML, IMG_DEFAULT_P, IMG_SNS_CONNECT_L, IMG_STAMP_ONE_L, IMG_STAMP_TWO_L, IMG_STAMP_THREE_L, IMG_MISSED_L, IMG_DEFAULT_L, nil];
    }
    
    if (isPortraitMode == YES) {
        [self viewPositioningWithModePortrait];
    } else {
        [self viewPositioningWithModeLandScape];
    }
    
    alert_dv_fb = [[UIAlertView alloc] initWithTitle:@"SecondCommercials" message:@"Congrats! We've just issued a digital coupon for you! Please check your Facebook account email!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Redeem", nil];
    alert_dv_tw = [[UIAlertView alloc] initWithTitle:@"SecondCommercials" message:@"Congrats! We've just issued a digital coupon for you! Please check your Twitter Direct Message!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Redeem", nil];
    
    self.view = scmAdView;
    
    /***************************************************/
    
    /*
    // Facebook Initiation
    facebook = [[Facebook_Scm alloc] initWithAppId:FB_APP_ID andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    */
    
    
    
    
    // Twitter Initiation
    twHandler = [[TwitterHandler alloc] init];
    
    // initiate DataStructure for plist infor file
    dictXmlInfo = [[NSMutableDictionary alloc] init];
    
    isMissedView = NO;
    isSnsLoginView = NO;
    isInternetAvailable = YES;
    isNoCampaignView = NO;
    isDownloading = NO;
    
    isFacebookLogin = NO;
    isTwitterLogin = NO;
        
    isCountryCodeMatch = YES;
    
    fb_email = nil;
    fb_name = nil;
    fbContainer = [[NSMutableDictionary alloc] init];
    twContainer = [[NSMutableDictionary alloc] init];
    
    [self scmAdSyncToServer];
        
    return self;
}


- (void) scmClearScmAd
{
    [scmAdView release];
}




#pragma - Facebook Delegate methods
- (void) scmAdFacebookLogin: (id)sender
{
   
    
    /*
    //NSLog(@"SCM: Facebook Login!");
    NSArray *fbPermission = [[NSArray alloc] initWithObjects:@"publish_stream", @"email", nil];
    [facebook authorize:fbPermission];
    [fbPermission release];
    */
    
    NSArray *permissions = [NSArray arrayWithObjects:@"publish_stream", @"email", nil];
    [FBSession sessionOpenWithPermissions:permissions
                        completionHandler:
     ^(FBSession *session,
       FBSessionState status,
       NSError *error) {
         // if login fails for any reason, we alert
         if (error) {
             // TODO: Handle Facebook Login Error
         } else if (FB_ISSESSIONOPENWITHSTATE(status)) {
             // send our requests if we successfully logged in
             isFacebookLogin = YES;
             [self fbDidLogin];
         }
     }];
}

- (void)scmAdPostToFacebook
{
    NSLog(@"[scm]: post to facebook");
    // Post to Facebook
    NSString *fb_link = nil;
    NSString *fb_link_desc = nil;
    NSString *fb_ad_desc = nil;
    NSString *fb_picture = nil;
    
    NSString *fb_text_one = nil;
    NSString *fb_text_two = nil;
    NSString *fb_text_three = nil;
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES)
                           objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
    if ([fileMgr fileExistsAtPath:filePath]) {
        dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        fb_link = [dictXmlInfo objectForKey:@"fb_link"];
        fb_link_desc = [dictXmlInfo objectForKey:@"fb_link_desc"];
        fb_ad_desc = [dictXmlInfo objectForKey:@"fb_ad_desc"];
        fb_picture = [dictXmlInfo objectForKey:@"fb_picture"];
        
        fb_text_one = [dictXmlInfo objectForKey:@"fb_post_one"];
        fb_text_two = [dictXmlInfo objectForKey:@"fb_post_two"];
        fb_text_three = [dictXmlInfo objectForKey:@"fb_post_three"];
        
        dictXmlInfo = nil;
    }
    
    NSString *stampText = [[NSString alloc] init];
    if (stampsCounter == 1) {
        stampText = fb_text_one;
    } else if (stampsCounter == 2) {
        stampText = fb_text_two;
    } else if (stampsCounter == 3) {
        stampText = fb_text_three;
    }
    
    NSString *strPost = [[NSString alloc] initWithFormat:stampText, stampsCounter];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   strPost, @"message", fb_link_desc, @"name", fb_link, @"link", fb_ad_desc,  @"description", fb_picture, @"picture", nil];
    [strPost release];
    fb_link = nil, fb_link_desc=nil, fb_ad_desc=nil;
    
    //[facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self];
    [FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (error) {
             NSLog(@"[scm]: Post to Facebook Error with: %@", error.description);
         }
    }];
    
}

- (void) scmAdPostToTwitter
{
    NSLog(@"[scm]: - Post to Twitter");
    
    NSString *stampText = [[NSString alloc] init];    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES)
                           objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
    
    if ([fileMgr fileExistsAtPath:filePath]) {
        dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        
        if (stampsCounter == 1) {
            stampText = [dictXmlInfo objectForKey:@"tw_post_one"];
        } else if (stampsCounter == 2) {
            stampText = [dictXmlInfo objectForKey:@"tw_post_two"];
        } else if (stampsCounter == 3) {
            stampText = [dictXmlInfo objectForKey:@"tw_post_three"];
        }
        
        dictXmlInfo = nil;
    }
    
    stampText = [stampText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [twHandler twSendUpdate:stampText];
    [stampText release];
}

#pragma - send email for facebook user
- (void) sendMailToServer : (NSString *)email_address withName:(NSString *)user_name
{
    NSLog(@"[scm]: send email to facebook account!");
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* deviceID = [[UIDevice currentDevice] uniqueIdentifier];
    NSString* phpFile = [[NSString alloc] initWithFormat:@"%@/logic/sendMailToFacebook_3_0_2.php", SERVER_IP];
    NSURL *url = [NSURL URLWithString:phpFile];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        NSString *response = [[request responseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];        
        if ([response isEqualToString:@"successful"]) {
            
            NSLog(@"[scm]: - send email OK!");
        } else if ([response isEqualToString:@"failed"]) {
            NSLog(@"[scm]: - Send email failed!");
        }
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"[scm]: error - %@", error);
    }];
    
    [request setPostValue:@"SecondCommercials" forKey:@"id"];
    [request setPostValue:@"second1234567" forKey:@"passwd"];
    
    [request setPostValue:deviceID forKey:@"DeviceID"];
    [request setPostValue:appID forKey:@"AppID"];
    [request setPostValue:campaignName forKey:@"campaign"];
    
    [request setPostValue:email_address forKey:@"email"];
    [request setPostValue:user_name forKey:@"name"];
    
    [request setDelegate:self];
    [request setTimeOutSeconds: 300.0f];
    [request startAsynchronous];
}

#pragma - send DM for twitter user
- (void) sendDirectMessageToTwitter
{
    NSString *tw_dm = [[NSString alloc] init];;
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES)
                           objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
    if ([fileMgr fileExistsAtPath:filePath]) {
        twContainer = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        tw_dm = [twContainer objectForKey:@"tw_dm"];
        twContainer = nil;
    }
    
    tw_dm = [tw_dm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [twHandler twSendDirectMessage:tw_dm];
    [tw_dm release];
}

- (void) scmAdIssueDv
{
    if (stampsCounter == 3) {
        //NSLog(@"SCM: *--------* Stamp is three");
        if (isInternetAvailable == YES) {
            NSLog(@"[scm]: - Internet is available");
            
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
            if ([fileMgr fileExistsAtPath:filePath]) {
                dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
                [dictXmlInfo setObject:@"YES" forKey:@"digitalVoucher"];
                [dictXmlInfo writeToFile:filePath atomically:YES];
                
                
            }
            
            if (isFacebookLogin) {
                NSString *filePathFB = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_FB_PLIST];
                if ([fileMgr fileExistsAtPath:filePathFB]) {  
                    fbContainer = [[NSMutableDictionary alloc] initWithContentsOfFile:filePathFB];
                    fb_email = [fbContainer objectForKey:@"fb_email"];
                    fb_name = [fbContainer objectForKey:@"fb_name"];
                    // send email to user
                    if (fb_email && fb_name) {
                        digitalVoucher = @"YES";
                        [self sendMailToServer:fb_email withName:fb_name];
                        [alert_dv_fb show];
                    }
                    
                    fbContainer = nil;
                }
            } else if (isTwitterLogin) {
                
                if ([twAccount username]) {
                    [self sendDirectMessageToTwitter];
                    [alert_dv_tw show];
                }
                
                twContainer = nil;
            }
            
        }
    }
}


-(void)fbDidLogin
{
    NSLog(@"[scm]: - facebook login OK!");
    
    [UIView beginAnimations:@"HideSnsLoginView" context:(void *)scmAdView];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationDelegate:self];
    
    isSnsLoginView = NO;
    if (bannerPosition == BOTTOM) {
        scmAdSnsLoginView.frame = CGRectMake(0, 480, 320, 480);
    } else {
        if (isPortraitMode == YES) {
            scmAdSnsLoginView.frame = CGRectMake(0, -480, 320, 480);
        } else {
            scmAdSnsLoginView.frame = CGRectMake(0, -370, 480, 370);
        }
    }  
    
    scmAdSnsLoginView.alpha = 0.0f;
    [UIView commitAnimations];
    
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
            
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_FB_PLIST];
            
            if (fb_email && fb_name) {
                //NSLog(@"Write FB Info");
                [fbContainer setObject:fb_email forKey:@"fb_email"];
                [fbContainer setObject:fb_name forKey:@"fb_name"];
                [fbContainer writeToFile:filePath atomically:YES];
            }
            fbContainer = nil;
        }

    }];

    // Post first feed
    if (isMissedView == NO) {
        //NSLog(@"SCM - Post to Facebook!");
        [self scmAdPostToFacebook];
        [self scmAdIssueDv];
        
        if (stampsCounter == 3) {
            [alert_dv_fb show];
        }
    }

}

-(BOOL)checkForPreviouslySavedAccessTokenInfo
{
    
    if (isFacebookLogin || isTwitterLogin) {
        return YES;
    } else {
        return NO;
    }
     
}

/*
- (void) request:(FBRequest_Scm*)request didLoad:(id)result
{
    if ([result isKindOfClass:[NSDictionary class]])
    {
        fb_email = [result objectForKey: @"email"];
        fb_name = [result objectForKey: @"name"];
        //NSString *facebookId = [result objectForKey: @"id"];
        //NSLog(@"Facebook Email: %@", fb_email);
        //NSLog(@"Facebook Name: %@", fb_name);
        //NSLog(@"FacebookID: %@", facebookId);
        
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_FB_PLIST];

            if (fb_email && fb_name) {
                //NSLog(@"Write FB Info");
                [fbContainer setObject:fb_email forKey:@"fb_email"];
                [fbContainer setObject:fb_name forKey:@"fb_name"];
                [fbContainer writeToFile:filePath atomically:YES];
            }
            fbContainer = nil;
    }
} 
*/


#pragma - Twitter Delegate Methods
- (void) scmAdTwitterLogin: (id)sender
{
    NSLog(@"[scm] - Twitter Login");
    if (![TWTweetComposeViewController canSendTweet]) {
        //twController.view.hidden = YES;

        [twController.view removeFromSuperview];
        [self presentModalViewController:twController animated:YES];
        [twController.view endEditing:YES];

    } else {
        
        isTwitterLogin = [twHandler twLogin];
 
        if (isTwitterLogin == YES) {
            [UIView beginAnimations:@"HideSnsLoginView" context:(void *)scmAdView];
            [UIView setAnimationDuration:1.0f];
            [UIView setAnimationDelegate:self];
            
            isSnsLoginView = NO;
            if (bannerPosition == BOTTOM) {
                scmAdSnsLoginView.frame = CGRectMake(0, 480, 320, 480);
            } else {
                if (isPortraitMode == YES) {
                    scmAdSnsLoginView.frame = CGRectMake(0, -480, 320, 480);
                } else {
                    scmAdSnsLoginView.frame = CGRectMake(0, -370, 480, 370);
                }
            }
            
            scmAdSnsLoginView.alpha = 0.0f;
            [UIView commitAnimations];
            
            if (isMissedView == NO) {
                [self scmAdPostToTwitter];
                [self scmAdIssueDv];
                
                if (stampsCounter == 3) {
                    [alert_dv_tw show];
                }
            }

        } else {
            // Should never visit here
        }
        
        
    }
    
}


#pragma - animation callback methods
- (void)scmAdAnimationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context 
{
    //NSLog(@"Animation Finished!");
    
    if ([animationID isEqualToString:@"closeStampView"]) {
        if (isMissedView)
            isMissedView = NO;

        [self scmAdSyncToServer];
        // call delegate mathod
        [[self scmAdDelegate] scmAdViewDidFinish];

    }
    
    if ([animationID isEqualToString:@"showStampView"] && isNoCampaignView == NO) {
        // Save click impressions
        // Save stampsCounter to Plist file
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
        if ([fileMgr fileExistsAtPath:filePath]) {
            dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
            
            // save stampx_banner_click to plist file
            if (isMissedView) {
                [dictXmlInfo setObject:[[NSString alloc] initWithFormat:@"%d", ++missed_ad_counter] forKey:@"missed_banner_click"]; 
                
                // check for first_missed_time and assign it if it's 0
                
                NSString *oldDateTIme = [dictXmlInfo objectForKey:@"first_missed_time"];

                if ([oldDateTIme isEqualToString:@"0000-00-00 00:00:00"]) {
                    NSString *dateTime = [self getCurrentDateTime];
                    [dictXmlInfo setObject:dateTime forKey:@"first_missed_time"];
                }
                
            } 
            else if (stampsCounter == 1) {
                [dictXmlInfo setObject:[[NSString alloc] initWithFormat:@"%d", ++stamp1_ad_counter] forKey:@"stamp1_banner_click"];  
             
                // Record first stamp time
                NSString *dateTime = [self getCurrentDateTime];
                [dictXmlInfo setObject:dateTime forKey:@"first_stamp_time"];
            }
            else if (stampsCounter == 2) {
                [dictXmlInfo setObject:[[NSString alloc] initWithFormat:@"%d", ++stamp2_ad_counter] forKey:@"stamp2_banner_click"];  
                
                // Record second stamp time
                NSString *dateTime = [self getCurrentDateTime];
                [dictXmlInfo setObject:dateTime forKey:@"second_stamp_time"];
            }
            else if (stampsCounter == 3) {
                [dictXmlInfo setObject:[[NSString alloc] initWithFormat:@"%d", ++stamp3_ad_counter] forKey:@"stamp3_banner_click"];
             
                // Record third stamp time
                NSString *dateTime = [self getCurrentDateTime];
                [dictXmlInfo setObject:dateTime forKey:@"third_stamp_time"];

            }
            
            
            // Update plist stamps info
            [dictXmlInfo setObject:[[NSString alloc] initWithFormat:@"%d", stampsCounter] forKey:@"stamps"];
            
            [dictXmlInfo writeToFile:filePath atomically:YES];
            dictXmlInfo = nil;
            
        }
        // Show sns view
        if ([self checkForPreviouslySavedAccessTokenInfo] == NO && isInternetAvailable == YES) {
            
            if (isPortraitMode == YES) {
                scmAdSnsLoginView.frame = CGRectMake(0, 0, 320, 480);
            } else {
                scmAdSnsLoginView.frame = CGRectMake(0, 0, 480, 320);
            }
            
            [UIView beginAnimations:@"ShowSnsLoginView" context:(void *)scmAdSnsLoginView];
            [UIView setAnimationDuration:1.0f];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDelay:1.0f];
            //scmAdSnsLoginView.frame = CGRectMake(0, 0, 320, 480);
            [scmAdSnsLoginView setAlpha:1.0f];
            isSnsLoginView = YES;
            [UIView commitAnimations]; 
        } else if (isInternetAvailable == YES && isNoCampaignView == NO) {
            if (isFacebookLogin) {
                [self scmAdPostToFacebook];
            } else if (isTwitterLogin) {
                [self scmAdPostToTwitter];
            }
            [self scmAdIssueDv];

        }        
    }
}


#pragma - NSXMLParser Delegate methods

- (void) parserDidStartDocument:(NSXMLParser *)parser
{
    currentElement = nil;
    xmlContainer = [[NSMutableDictionary alloc] init];
}

- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"[scm]: XMLParser Error: %@", [parseError localizedDescription]);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentElement = elementName;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{    
    //NSLog(@"object - %@, key - %@", string, currentElement);
    [xmlContainer setObject:string  forKey:currentElement];
    
    if ([currentElement isEqualToString:@"hurdle"]) {
        hurdlePoint = [string intValue];
    } else if ([currentElement isEqualToString:@"campaign"]) {
        campaignName = string;
    } else if ([currentElement isEqualToString:@"countryCode"]) {
        NSLog(@"[scm]: parse campaign country code: %@", string);
        campaignCountryCode = string;
    } else if ([currentElement isEqualToString:@"hurdle_x_p"]) {
        hurdle_x_p = [string intValue];
    } else if ([currentElement isEqualToString:@"hurdle_y_p"]) {
        hurdle_y_p = [string intValue];
    } else if ([currentElement isEqualToString:@"hurdle_w_p"]) {
        hurdle_w_p = [string intValue];
    } else if ([currentElement isEqualToString:@"hurdle_y_p"]) {
        hurdle_h_p = [string intValue];
    } else if ([currentElement isEqualToString:@"hurdle_x_l"]) {
        hurdle_x_l = [string intValue];
    } else if ([currentElement isEqualToString:@"hurdle_y_l"]) {
        hurdle_y_l = [string intValue];
    } else if ([currentElement isEqualToString:@"hurdle_w_l"]) {
        hurdle_w_l = [string intValue];
    } else if ([currentElement isEqualToString:@"hurdle_y_l"]) {
        hurdle_h_l = [string intValue];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    currentElement = nil;
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
    
    if ([fileMgr fileExistsAtPath:filePath]) {
        if ([fileMgr removeItemAtPath:filePath error:nil]!=YES) {
            //NSLog(@"Unable to delete file: %@", [error localizedDescription]);
            //NSLog(@"Unable to delete file!");
        }
    }
    
    [xmlContainer writeToFile:filePath atomically:YES];
    [xmlContainer release];
    
}


#pragma - UIAlertView Delegate Mathod

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //NSLog(@"Button Index 0");
    } else {
        //NSLog(@"Button Index 1");
        
        // Redirect to campaign URL
        //NSLog(@"Open URL!!");
        NSURL *url = [NSURL URLWithString:campaignUrl];
        [[UIApplication sharedApplication] openURL:url];
        //NSLog(@"Open a URL");
    }
}























@end
