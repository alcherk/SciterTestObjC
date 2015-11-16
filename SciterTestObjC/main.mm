//
//  main.m
//  SciterTestObjC
//
//  Created by Aleksey Cherkasskiy on 16/11/15.
//  Copyright © 2015 Alcherk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/NSApplication.h>

#import "MainWindow.h"
#include "resources.cpp"

extern NSView*   get_nsview(MainWindow* w);
extern NSWindow* get_nswindow(MainWindow* w);

#define WINDOW_WIDTH 500
#define WINDOW_HEIGHT 350

int main(int argc, const char * argv[])
{
    NSApplication * application = [NSApplication sharedApplication];
    
    sciter::archive::instance().open(aux::elements_of(sciter_resources)); // bind resources[] (defined in "resources.cpp") with the archive
    
    NSScreen *mainScreen = [NSScreen screens][0];
    CGFloat marginLeft = (mainScreen.frame.size.width - WINDOW_WIDTH) / 2;
    CGFloat marginTop = (mainScreen.frame.size.height - WINDOW_HEIGHT) / 2 - 50;
    
    RECT frame;
    frame.top = marginTop;
    frame.left = marginLeft;
    frame.right = marginLeft + WINDOW_WIDTH + 1;
    frame.bottom = marginTop + WINDOW_HEIGHT + 1;
    
    aux::asset_ptr<MainWindow> wnd = new MainWindow(WSTR("this://app/default.htm"),frame);
    
    //sciter::debug_output debug_console(wnd->get_hwnd());
    
    [get_nswindow(wnd) makeKeyAndOrderFront: nil];
    
    [application run];
    
}
