//
//  KSLayer.cpp
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 10/14/23.
//

#include "KSLayer.hpp"
#include <string>
#include "KSImage.hpp"
#include "KSImageLoader.hpp"
#include "KSLog.hpp"


bool KSLayer::process(KSLayer *baseLayer)
{
     /*
     */
    //set baseLayer as the frameBuffer
    //Process and Render Current Layer on to the base Layer.
    //Check if the coordinates can be saved in the base layer for touch.
    
    return true;
}

void KSLayer::resize(int32_t width, int32_t height)
{
    this->width = width;
    this->height = height;
    //TODO realize
}

void KSLayer::addImage(const char *path)
{
    KSImage *image = KSImageLoader::loadImage(path);//TODO load Asynchronous;
    
    if(image == nullptr)
    {
        KSLogE("Layer Error adding image - nuLL");
        return;
    }
     
    KSLogD("Layer : add Image %s , width %d ,height %d",path,image->getWidth(),image->getHeight());
    
    std::lock_guard<std::mutex> lock(imagesLock);
   
    images.push_back(image);
    
     
    
    
}
