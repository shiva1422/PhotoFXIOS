//
//  KSImageLoader.hpp
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 10/20/23.
//

#ifndef KSImageLoader_hpp
#define KSImageLoader_hpp

#include <stdio.h>
#include "KSImage.hpp"
#include <string>

class KSImageDecodeListener{
    
public:
    
    void onImageAvailable(KSImage* image);
};

class KSImageLoader{
    
public:
    
    static KSImage *loadImage(const char *path);
    
   static void loadImageAsync(std::string path,KSImageDecodeListener *listener);
};
#endif /* KSImageLoader_hpp */
