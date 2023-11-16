//
//  KSFilterRenderer.h
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 11/13/23.
//

#import "KSTextureRenderer.h"
#import "FilterCommon.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSFilterRenderer : NSObject <KSMetalViewDelegate>

/*generally 0.0 - 1.0*/
-(void) setLogContrastScale:(float)scale;

@end

NS_ASSUME_NONNULL_END
