//
//  MainWindow.h
//  SciterTestObjC
//
//  Created by Aleksey Cherkasskiy on 16/11/15.
//  Copyright © 2015 Alcherk. All rights reserved.
//

#ifndef main_window_h
#define main_window_h

#include "sciter-x.h"
#include "aux-asset.h"
#include "aux-cvt.h"

bool get_sciter_resource(const char* name, const byte* &data, size_t& data_length);

class MainWindow: public aux::asset,
public sciter::host<MainWindow>,
public sciter::event_handler
{
    HWINDOW hwnd;
public:
    MainWindow(LPCWSTR url, RECT frame)
    {
        hwnd = SciterCreateWindow(SW_MAIN | SW_ENABLE_DEBUG, &frame, 0,0,0);
        setup_callback(hwnd);
        sciter::attach_dom_event_handler(hwnd, this);
        load_file(url);
        aux::asset::add_ref();
    }
    
    LRESULT on_engine_destroyed() { aux::asset::release(); return 0; }
    
    LRESULT on_load_data(LPSCN_LOAD_DATA pnmld)
    {
        aux::wchars wu = aux::chars_of(pnmld->uri);
        if(wu.like(WSTR("this://app/*"))) {
            // try to get them from archive first
            aux::bytes adata = sciter::archive::instance().get(wu.start+11);
            if(adata.length)
                ::SciterDataReady( pnmld->hwnd, pnmld->uri, adata.start, adata.length);
        }
        return LOAD_OK;
    }
    
    bool load_resource_data(LPCWSTR uri, LPCBYTE& pbytes, UINT& nbytes ) {
        aux::wchars wu = aux::chars_of(uri);
        if(wu.like(WSTR("this://app/*"))) {
            // try to get them from archive first
            aux::bytes adata = sciter::archive::instance().get(wu.start+11);
            pbytes = adata.start;
            nbytes = adata.length;
            return true;
        }
        return false;
    }
    
    HWINDOW   get_hwnd() const { return hwnd; }
    HINSTANCE get_resource_instance() const { return 0; /*not used on this platform*/ }
    
    BEGIN_FUNCTION_MAP
        FUNCTION_1("join_meeting", join_meeting);
    END_FUNCTION_MAP
    
    sciter::value join_meeting(sciter::value meeting_id);    
};

#endif
