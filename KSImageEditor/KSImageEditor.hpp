//
//  KSImageEditor.hpp
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 10/14/23.
//

#ifndef KSImageEditor_hpp
#define KSImageEditor_hpp

#include <stdio.h>
#include <stdint.h>
#include <vector>
#include "Layer/KSLayer.hpp"


struct KSImageEditor{
    
public:
    
    KSImageEditor(){}
    
    ~KSImageEditor();
    
    /*create image editor with final export resolution.First layer(0) will be created during the construction and the first layer will always be of this resolution
    */
    
    KSImageEditor(int32_t width,int32_t height);
    
    void setResolution(int32_t widht,int32_t height);
    
    bool process();
    
    //Image operations
    
    void addImage(const char* URL);
    
    
    //Layer operations
    
    void addLayer(KSLayer *layer);
    
    void removeLayer(int32_t layerNumber);
    
    //Editing Operations will be performed on active layer(selected layer).
    KSLayer* getActiveLayer(){return activeLayer;};//
    
    
    
    
private:
    
    //TODO layer Graph.
    std::vector<KSLayer *> layers;
    
    KSLayer *activeLayer = nullptr;
    
    //postProcess output Layer of all layers Blended together or final image of all editing .
    KSLayer *postProcessLayer = nullptr;
    
    
    
    
};

/*
 Later move all layer operations to layerController.
 */

#endif /* KSImageEditor_hpp */
