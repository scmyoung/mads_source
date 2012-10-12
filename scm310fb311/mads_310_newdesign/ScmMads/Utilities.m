//
//  Utilities.m
//  ScmMads
//
//  Created by Yongmo on 8/17/12.
//  Copyright (c) 2012 SecondCommercials. All rights reserved.
//

#import "Utilities.h"
#import "Macros.h"

@implementation Utilities {
    NSString *currentElement;
    NSFileManager *fileMgr;
}

@synthesize xmlParser;
@synthesize xmlContainer;
@synthesize alert_dv_fb;
@synthesize alert_dv_tw;
@synthesize alert_logPs;

- (id) init {
    
    self = [super init];
    alert_dv_fb = [[UIAlertView alloc] initWithTitle:@"SecondCommercials" message:@"Congrats! Just issued a digital coupon for you!!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Redeem", nil];
    alert_dv_tw = [[UIAlertView alloc] initWithTitle:@"SecondCommercials" message:@"Congrats! Just issued a digital coupon for you!!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Redeem", nil];
    alert_logPs = [[UIAlertView alloc] initWithTitle:@"secondCommercials" message:@"passbook" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];

    return self;
}

- (NSString *)stringByDecodingURLFormat:(NSString *)input
{
    return [[input stringByReplacingOccurrencesOfString:@"+" withString:@" "]
            stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == alert_dv_fb || alert_dv_tw ==alertView)
    {
        
    
        if (buttonIndex == 0) {
        
        } else if (buttonIndex == 1) {
        
            NSString *redeemUrl = @"";
            NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES)
                               objectAtIndex:0] stringByAppendingPathComponent:SCM_AD_PLIST];
            if ([fileMgr fileExistsAtPath:filePath]) {
                NSMutableDictionary *dictXmlInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
                //redeemUrl = [dictXmlInfo objectForKey:@"redeem_link"];
                redeemUrl = [self stringByDecodingURLFormat:[dictXmlInfo objectForKey:@"redeem_link"]];
                dictXmlInfo = nil;
            }

            NSLog(@"URL: %@", redeemUrl);
            NSURL *url = [NSURL URLWithString:[redeemUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    
    if (alertView == alert_logPs) {
        NSLog(@"alert_logPs");
        
    }
}

- (NSString *)getCurrentDateTime
{
    NSDate *tmpDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    [dataFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    NSString *dateString = [dataFormatter stringFromDate:tmpDate];
    return dateString;
}


#pragma - NSXMLParser Delegate methods

- (void)parseScmAdXmlFile: (NSData *)fileData
{
    xmlParser = [[NSXMLParser alloc] initWithData:fileData];
    [xmlParser setDelegate:self];
    [xmlParser setShouldProcessNamespaces:NO];
    [xmlParser setShouldReportNamespacePrefixes:NO];
    [xmlParser setShouldResolveExternalEntities:NO];
    [xmlParser parse];
}

- (void) parserDidStartDocument:(NSXMLParser *)parser
{
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
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    currentElement = nil;
    fileMgr = [NSFileManager defaultManager];

    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:@"scmAdPlist.plist"];
    
    if ([fileMgr fileExistsAtPath:filePath]) {
        [fileMgr removeItemAtPath:filePath error:nil];
    }
    
    [xmlContainer writeToFile:filePath atomically:YES];
    xmlContainer = nil;
    
}



@end
