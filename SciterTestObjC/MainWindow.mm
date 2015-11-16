//
//  MainWindow.m
//  SciterTestObjC
//
//  Created by Aleksey Cherkasskiy on 16/11/15.
//  Copyright © 2015 Alcherk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindow.h"

#define BACKEND_URL @"https://www.freeconferencecall.com/api/v3/subscriptions/by_meeting_id?id="


NSView*   get_nsview(MainWindow* w)   { return (__bridge NSView*)(w->get_hwnd()); }
NSWindow* get_nswindow(MainWindow* w) { return [get_nsview(w) window]; }

sciter::value MainWindow::join_meeting(sciter::value meeting_id)
{
    NSString *mID = [NSString stringWithFormat:@"%S", meeting_id.to_string().c_str()];
    NSLog(@"Meeting ID: %@", mID);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BACKEND_URL, mID]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                call_function("network_error", meeting_id);
            }];
        }
        else{
            __block NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", json);
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
                if (HTTPStatusCode != 200) {
                    NSLog(@"HTTP status code = %ld", (long)HTTPStatusCode);
                    call_function("network_error", meeting_id);
                }

                if (json[@"retcode"] != nil && [json[@"retcode"] longValue] == 0) {
                    call_function("success", meeting_id);
                }
                else {
                    call_function("error", meeting_id);
                }
            }];
        }
    }];
    
    [task resume];
//    sciter::value vars;
//    vars.set_item(sciter::value("on-glass"), on_off);
//    SciterSetMediaVars(get_hwnd(), &vars);
    
    return sciter::value(true);
}