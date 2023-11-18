//
//  KSFilterRenderer.h
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 11/13/23.
//

#import "KSTextureRenderer.h"
#import "FilterCommon.hpp"

NS_ASSUME_NONNULL_BEGIN

@interface KSFilterRenderer : NSObject <KSMetalViewDelegate>

/*generally 0.0 - 1.0*/
-(void) setLogContrastScale:(float)scale;

-(void) setImage:(const char*) url;

-(void) updateFilterParams:(FilterParams)params;

-(void)setActiveFragShader:(std::string)frag;

@end

NS_ASSUME_NONNULL_END
