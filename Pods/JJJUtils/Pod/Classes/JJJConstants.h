//
//  JJJConstants.h
//  JJJ
//
//  Created by Jovito Royeca on 2/3/14.
//  Copyright (c) 2014 Jovito Royeca. All rights reserved.
//

#ifndef JJJConstants_h
#define JJJConstants_h

#ifdef _WIN64
    #define _OS_WIN64 1
#elif _WIN32
    #define _OS_WIN32 1
#elif __APPLE__
    #include "TargetConditionals.h"
    #if TARGET_OS_IPHONE && TARGET_IPHONE_SIMULATOR
        #define _OS_IPHONE_SIMULATOR 1
    #elif TARGET_OS_IPHONE
        #define _OS_IPHONE 1
    #else
        #define _OS_OSX 1
    #endif
#elif __linux
    #define _OS_LINUX 1
#elif __unix
    #define _OS_UNIX 1
#elif __posix
    #define _OS_POSIX 1
#endif

#endif