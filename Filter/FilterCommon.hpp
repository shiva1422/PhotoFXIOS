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


enum EFilterType{LOG,EXPONENTIAL,POWER_LAW};

enum EAuto{NEGATIVE};

/*
 Auto is where filter params are constant ,whereas Variable means filter parameters can be changed through slider.
 */

enum EActiveEditType{Auto,Variable};

struct FilterParams{
    
    float alpha = 0.0;
    float scaleFactor[4] = {1.0,1.0,1.0,1.0};
};

class ImageFilter{
   
private:
    FilterParams params;
    EActiveEditType editType = Variable;
    EFilterType filterType;
    EAuto autoType;
};


/*Variable Filters :
 Power Law = Log + Exp ;Exp and Log are mirrors around y=x;
 *Log increases darker range to bright while keeping higher range to almost same while Exp increases brighness of higher end of pixel while keeping lower end almost same:
 
 1.Log : implemented : t
  Todo separate r,g,b,rg,gb,br.
 */

#endif /* FilterCommon_hpp */
