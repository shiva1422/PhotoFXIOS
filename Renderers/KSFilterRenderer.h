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

-(void)updateParams;

@end

NS_ASSUME_NONNULL_END
