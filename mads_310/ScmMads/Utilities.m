//
//  Utilities.m
//  ScmMads
//
//  Created by Yongmo on 8/17/12.
//  Copyright (c) 2012 SecondCommercials. All rights reserved.
//

#import "Utilities.h"
#import "macro.h"

@implementation Utilities {
    NSString *currentElement;
    NSFileManager *fileMgr;
}

@synthesize xmlParser;
@synthesize xmlContainer;

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
    
    /*
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
     */
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
