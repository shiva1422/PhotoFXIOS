//
//  FilterCommon.cpp
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 11/14/23.
//

#include "FilterCommon.hpp"



static void getIntensityFragName(std::string option,std::string &shader)
{
    if(option == "log")
    {
        shader = "logIntensity";
    }
    else if (option == "power")
    {
        shader = "powerIntensity";
    }
    else if(option == "bright")
    {
        shader = "hsi";
    }
    else if(option == "contrast")
    {
        shader = "contrast";
    }
    else if(option == "slice")
    {
        shader = "slice";
    }
}

std::string ImageEditContext::getFragmentShaderName(std::string mainOption, std::string subOption)
{
    std::string shaderName = "frag";//default
    
    //matching UI title
    
    if(mainOption == "Intensity")
    {
        getIntensityFragName(subOption,shaderName);
    }
    
    return shaderName;
    
}
