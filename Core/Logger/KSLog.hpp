//
//  KSLog.hpp
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 10/18/23.
//

#ifndef KSLog_hpp
#define KSLog_hpp

#include <stdio.h>
#include <syslog.h>

#define KSLogI(fmt,...) syslog(LOG_INFO,fmt,##__VA_ARGS__)
#define KSLogD(fmt,...) syslog(LOG_DEBUG,fmt,##__VA_ARGS__)
#define KSLogE(fmt,...) syslog(LOG_ERR,fmt,##__VA_ARGS__)

#endif /* KSLog_hpp */
