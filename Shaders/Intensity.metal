//
//  Intensity.metal
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 11/13/23.
//

#include <metal_stdlib>
//#include "../Filter/FilterCommon.hpp"
using namespace metal;
/*
 Intensity Transformations.
 */

struct Vertex
{
    float4 position [[position]];
    float2 UV;
};

struct Uniforms
{
    float4x4 mvpMatrix;
};

//KeepSame as FilterCommon.hpp//Later also consider type sizes float32,halfFloat etc.//Move to shader common;
struct FilterParams{
    
    float scaleFactor[4];
    int flags[4] = {1,1,1,1};//bool rEnable,bEnable,gEnable,AEnable;
    float alpha ;
    bool bGrayScale= false;
};

vertex Vertex vertIntensity(const device Vertex *vertices [[buffer(0)]] , constant Uniforms *uniforms [[buffer(1)]],uint vid[[vertex_id]])
{
    Vertex vout;
    vout.position = vertices[vid].position;
    vout.UV = vertices[vid].UV;
    return vout;
}

fragment float4 fragIntensity(Vertex inVertex[[stage_in]] ,texture2d<float>text[[texture(0)]],constant FilterParams *filter[[buffer(2)]])
{
    constexpr sampler textureSampler(coord::normalized,address::repeat,filter::linear);
    float4 sampledColor = text.sample(textureSampler, inVertex.UV);
    
    FilterParams tempFil;
    sampledColor.r = tempFil.alpha;
    //sampledColor = float4(sampledColor.r)
    return sampledColor;
}

/*
  *brightens lower end range of intensities while keeping upper range almost same or moving to gray
  * s = c * log( 1 +r);
  *a s= c * log(1+r) ;as r ranges from 0-255,log(1+r) ranges from 0 - 2.4;this makes it a dark image so span the output to range of 0-255 scale factor is used.generall c = 255/(log(rmax + 1); c depends on max vallue of pixel in the image and bit depth.
      rmax should be max value in the image(TODO) but for most(high contrast cases can be taken as rmax = 255 ; which give c = 105.886; but there we have normalized 0- 1.0 .so apply scale as 1.0 and can be multipled in range 1.0 - 5.0;optimal can go up as well
 */

fragment float4 logIntensity(Vertex inVertex[[stage_in]] ,texture2d<float>text[[texture(0)]],constant FilterParams *filter[[buffer(2)]])
{
    constexpr sampler textureSampler(coord::normalized,address::repeat,filter::linear);
    float4 sampledColor = text.sample(textureSampler, inVertex.UV);
    
   //
    //gray = 10.0 * log(1 + gray);
    //sampledColor.rgb = float3(gray,gray,gray);//TODO grayscale
    if(filter->bGrayScale * 1 != 0)
    {
        float gray = (sampledColor.r + sampledColor.g + sampledColor.b)/3.0;
        gray = filter->scaleFactor[0] * log(1+gray);
        sampledColor.r = gray;
        sampledColor.g = gray;
        sampledColor.b = gray;

    }
    else
    {
       
        sampledColor.r = filter->scaleFactor[0] * log(1 + sampledColor.r);
        sampledColor.g = filter->scaleFactor[1] * log(1 + sampledColor.g);
        sampledColor.b = filter->scaleFactor[2] * log(1 + sampledColor.b);
    }
   

    //sampledColor = float4(sampledColor.r)
    return sampledColor;
}

/*
 gamma correction generally used where CRT display used to cause intensity variation of with power around gamma = 2.2 to get a linear curve of image display by inverting gamma around 0.4;gamma < 1 behave as log,while > 1 behaves has exponential;
 */
fragment float4 powerIntensity(Vertex inVertex[[stage_in]] ,texture2d<float>text[[texture(0)]],constant FilterParams *filter[[buffer(2)]])
{
    constexpr sampler textureSampler(coord::normalized,address::repeat,filter::linear);
    float4 sampledColor = text.sample(textureSampler, inVertex.UV);
    
   //
    //gray = 10.0 * log(1 + gray);
    //sampledColor.rgb = float3(gray,gray,gray);//TODO grayscale
    if(filter->bGrayScale * 1 != 0)
    {
        float gray = (sampledColor.r + sampledColor.g + sampledColor.b)/3.0;
        gray = filter->scaleFactor[0] * log(1+gray);
        sampledColor.r = gray;
        sampledColor.g = gray;
        sampledColor.b = gray;

    }
    else
    {
       //todo variation of C = 2.0;
        sampledColor.r = 2.0 * metal::powr(sampledColor.r,filter->scaleFactor[0]);
        sampledColor.g = 2.0 * metal::powr(sampledColor.g,filter->scaleFactor[1]);
        sampledColor.b = 2.0 * metal::powr(sampledColor.b,filter->scaleFactor[2]);
    }
   

    //sampledColor = float4(sampledColor.r)
    return sampledColor;
}


