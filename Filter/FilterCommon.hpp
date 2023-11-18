//
//  FilterCommon.hpp
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 11/14/23.
//

#ifndef FilterCommon_hpp
#define FilterCommon_hpp

#include <stdio.h>
#include <string>
/*TODO later Separte Filters as required and EditCOntrol*/

enum EEditType{Intensity,HSI,Blur};
enum EActiveChannel{RGB = 0,R,G,B,A,RG,GB,RB};

/*
 LOG : Shadow ,highlighs
 keep slider range 0-3 or upto 10;
 Power Law : EXPO +
 
 
 TODO:
 EXPO
 */
enum EIntesityType{LOG,EXPONENTIAL,POWER_LAW};



enum EAuto{NEGATIVE};

/*
 Auto is where filter params are constant ,whereas Variable means filter parameters can be changed through slider.
 */

enum EActiveEditType{Auto,Variable};

struct FilterParams{
    
    float scaleFactor[4] = {1.0,1.0,1.0,1.0};
    int flags[4] = {1,1,1,1};//bool rEnable,bEnable,gEnable,AEnable;
    float alpha = 0.0;
    bool bGrayScale= false;

};

    

class ImageEditContext{
   
public:
    FilterParams params;
    EActiveEditType editType = Variable;
    EIntesityType filterType;
    EAuto autoType;
    EActiveChannel channel;

    
    bool sliderLock = true;
    bool grayScaleSwitch = false;
    
    static std::string getFragmentShaderName(std::string mainOption,std::string subOption);


    
};


/*Variable Filters :
 Power Law = Log + Exp ;Exp and Log are mirrors around y=x;
 *Log increases darker range to bright while keeping higher range to almost same while Exp increases brighness of higher end of pixel while keeping lower end almost same:
 
 1.Log : implemented :
  :range (scale factor determinees)edting experience lower range more control higher range more visibility
  :keep it 0 -5 or o -10;
  Todo separate r,g,b,rg,gb,br.
 2.EXPO : TODO;
 
 3 .Power law : todo separate gammas and scales for each channel.
    //keep range between 0 -1 and then 1-/3/5/10
 */

#endif /* FilterCommon_hpp */
