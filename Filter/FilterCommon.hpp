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
    //keep range between 0 -1 and then 1-/3/5/10/25
 */

//Above can be achieved by piecewise linear transofrmations
/*
 1.Contrast streching.
 ( r . sy) and ( r , sy)control the shapeo f the transformation func- tion. If r, = st and rz = sz, the transformation is a linear function that produces no changes in intensity levels. If r, = r2, s, = 0 and s2 = L - 1, the transformation becomes a thresholding finction that creates a binary image.
    Intermediate values of (r), sy) and (rz, s2) produce various degrees of spread in the intensity levels of the output image, thus affecting its contrast. In gen- eral, r1 <= r2 and s1 <= s2 is assumed so that the function is single valued and mo- notonically increasing.This condition preserves the order of intensity levels, thus
    preventing the creation of intensity artifacts in the processed image.
  
 TODO : Now only same r,s used for r,g,b,Thresholding.Later try different for all.Create Curve with (rn,sn),
 
 2.Intensity level slicing :
 slicing,can be implemented in several wavs. but most arevariations of twobasic themes. One approach is to display in one value (say, white) all the values in the range of interest and in another (sav, black) all other intensities. This transfor- mation, shown in Fig. 3.11(a), produces a binary image. The second approach, based o n the transformation in Fig. 3.1 ( b ) , brightens (or darkens) the desired range of intensities but leaves all other intensity levels in the image unchanged.
 *set intensity between r1 and r2 to s;
  
 TODO variation for each channel;
 
 */


#endif /* FilterCommon_hpp */
