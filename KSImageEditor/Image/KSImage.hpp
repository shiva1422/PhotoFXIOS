//
//  KSImage.hpp
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 10/20/23.
//

#ifndef KSImage_hpp
#define KSImage_hpp

#include <stdio.h>
#include <stdint.h>

enum EPixelFormat{RGB8,RGBA8};

class KSImage{
    
public:
    
    ~KSImage()
    {
        delete data;
    }
    int getWidth(){return width;}
    int getHeight(){return height;}
    uint8_t* getData(){return data;}
    
    
private:
    
    int width = -1,height = -1;
    
    EPixelFormat pixelFmt;
    
    uint8_t *data = nullptr;
    
    friend class KSImageLoader;
};

#endif /* KSImage_hpp */
