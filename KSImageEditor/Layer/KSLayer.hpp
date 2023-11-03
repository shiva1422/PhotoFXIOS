//
//  KSLayer.hpp
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 10/14/23.
//

#ifndef KSLayer_hpp
#define KSLayer_hpp

#include <stdio.h>
#include <stdint.h>
#include <vector>
#include <string>
#include <set>
#include <mutex>
#include "KSImage.hpp"

struct KSLayerProperties{
        
    int32_t height = -1 , width = -1;

};

class KSLayer{
    
public:
    
    KSLayer();
    
    KSLayer(int32_t width,int32_t height){this->width = width;this->height = height;};
    
    void resize(int32_t width,int32_t height);
    
    //baseLayer(output layer) is the layer upon which this layer is rendered
    bool process(KSLayer *baseLayer);
    
    void addImage(const char* path);
    

    
private:
    
    uint32_t imageCount = 0;
    
    std::vector<KSImage *> images;//TODO clearing check memory management.//TODO create approriate structure.
        
        
    int32_t width = -1,height = -1;
    
    std::mutex imagesLock;

    std::vector<std::string> urls;
    
    //float background color
    float r = 0.0,g = 0.0,b = 0.0 ,a = 1.0;
    
    //total layer alpha ,to view layer below.
    float layerAlpha = 1.0;
    
    
    std::string layerName;//TODO default to layer_number.
    
    
    
    
    
    
};


#endif /* KSLayer_hpp */
