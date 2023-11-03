//
//  KSImageEditor.cpp
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 10/14/23.
//

#include "KSImageEditor.hpp"
#include "KSLog.hpp"
#include "KSImageLoader.hpp"

KSImageEditor::KSImageEditor(int32_t width,int32_t height)
{
    setResolution(width,height);
}

bool KSImageEditor::process()
{
    //TODO clear postProcessLayer,before process.
    
    for(auto layer : layers)
    {
        if(layer == nullptr || !layer->process(postProcessLayer))
        {
            KSLogE("ImageEditor Process Error");
            return false;
        }
       
    }
    return true;
}

void KSImageEditor::setResolution(int32_t width, int32_t height)
{
    //***TODO need to optimize check if postProcess already created
    KSLogD("Image Editor Resolution %d %d",width,height);
    if(layers.size() != 0)
    {
        layers[0]->resize(width, height);
        postProcessLayer->resize(width, height);
    }
    else
    {
        KSLayer *layer = new KSLayer(width,height);
        addLayer(layer);
        postProcessLayer = new KSLayer(width,height);
        
    }
}

/* Layer operations */


void KSImageEditor::addLayer(KSLayer *layer)
{
    layers.push_back(layer);
    
    this->activeLayer = layer;
}

void KSImageEditor::removeLayer(int32_t layerNumber)
{
    /*
     TODO
     1.get Layer at number;
     2.if this is activeLayer then change ActiveLayer to below layer.
     3.Consider case when there is only one layer.
     */
}


/*image operations*/

void KSImageEditor::addImage(const char *URL)
{
    KSLogD("KSImageEditor::addImage %s",URL);
    getActiveLayer()->addImage(URL);
   
    //activeLaddImage(URL);
}




KSImageEditor::~KSImageEditor()
{
    //TODO
    //clear layers
}
