//
//  FilterCommon.hpp
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 11/14/23.
//

#ifndef FilterCommon_hpp
#define FilterCommon_hpp

#include <stdio.h>

/*TODO later Separte Filters as required and EditCOntrol*/


enum EFilterType{NEGATIVE,LOG,EXPONENTIAL,POWER_LAW}

class ImageFilter{
    
public:
    
    float alpha = 0.0;
    float scaleFactor[4] = {1.0,1.0,1.0,1.0};
    
    
public:
    
};


/*
 Power Law = Log + Exp ;Exp and Log are mirrors around y=x;
 *Log increases darker range to bright while keeping higher range to almost same while Exp increases brighness of higher end of pixel while keeping lower end almost same:
 */

#endif /* FilterCommon_hpp */
