//
//  KSFilterRenderer.m
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 11/13/23.
//


#import "KSFilterRenderer.h"
#include "Model.h"
#include "memutils.h"
#include "FilterCommon.hpp"
#include <mutex>

#define flightBufferCount 3

static const uint32_t KSBufferAlignment = 256;

const KTextureModel textModel[]= {
    {.position={1.0f,1.0f,0.0f,1.0f},.UV={1.0f,1.0f}},
    {.position={1.0f,-1.0f,0.0f,1.0f},.UV={1.0f,0.0f}},
    {.position={-1.0f,-1.0f,0.0f,1.0f},.UV={0.0f,0.0f}},
    {.position={-1.0f,1.0f,0.0f,1.0f},.UV={0.0f,1.0f}},
};

const KBEIndex indices[] = {0,2,1,0,3,2};



 
@interface KSFilterRenderer()
{
    FilterParams filterParams;
    std::mutex filterLock;
}
@property (strong,nonatomic) id<MTLDevice> device;
@property (strong,nonatomic) id<MTLBuffer> vertexBuffer;
@property (strong,nonatomic) id<MTLBuffer> indexBuffer;
@property (strong,nonatomic) id<MTLBuffer> uniformBuffer;
@property (strong,nonatomic) id<MTLBuffer> filterParamBuffer;
@property (strong,nonatomic) id<MTLTexture> texture;

@property (strong) id<MTLCommandQueue> commandQueue;
@property (strong) id<MTLRenderPipelineState> renderPipelineState;
@property (strong) id<MTLDepthStencilState> depthStencilState;
@property (strong) dispatch_semaphore_t displaySemaphore;
@property (assign) NSInteger bufferIndex;
@property (assign) float rotationX,rotationY, time;

@end


@implementation KSFilterRenderer

-(instancetype)init
{
    if((self = [super init]))
    {
         filterParams.scaleFactor[0] = 20.0;
        _device = MTLCreateSystemDefaultDevice();
        _displaySemaphore = dispatch_semaphore_create(flightBufferCount);
        [self createPipeline];
        [self createBuffers];
    }
   
    return self;
}

-(void)createPipeline
{
    self.commandQueue = [self.device newCommandQueue];
    
    _texture = [self loadTexture:nil];//for now static load;
    
    NSError *libraryErr = nil;
    //NSString *libraryFile = [[NSBundle mainBundle] pathForResource:@"texture" ofType:@"metallib"];
    id<MTLLibrary> library = [self.device newDefaultLibrary];
    if(!library)
    {
        NSLog(@"Library error : %@" , libraryErr.localizedDescription);
    }
    //id<MTLFunction> vertextFunc = [library newFunctionWithName:@"vert"];
   // id<MTLFunction> fragmentFunc = [library newFunctionWithName:@"frag"];
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.vertexFunction = [library newFunctionWithName:@"vertIntensity"];
    pipelineDescriptor.fragmentFunction =[library newFunctionWithName:@"logIntensity"];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    self.depthStencilState = [self.device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
    
    NSError *err = nil;
    self.renderPipelineState = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&err];
    
    if(!self.renderPipelineState)
    {
        NSLog(@"Error Occured when creating render pipeline state : %@", err);
    }
    self.commandQueue = [self.device newCommandQueue];
}

-(void)createBuffers
{
    _vertexBuffer = [self.device newBufferWithBytes:textModel length:sizeof(textModel) options:MTLResourceCPUCacheModeDefaultCache];
    [_vertexBuffer setLabel:@"vertices"];
    
    _indexBuffer = [self.device newBufferWithBytes:indices length:sizeof(indices) options:MTLResourceOptionCPUCacheModeDefault];
    [_indexBuffer setLabel:@"indices"];
    
    _uniformBuffer = [self.device   newBufferWithLength:alignUp(sizeof(KUniform),KSBufferAlignment)*flightBufferCount options:MTLResourceCPUCacheModeDefaultCache];
    [_uniformBuffer setLabel:@"uniforms"];
    
    _filterParamBuffer = [self.device newBufferWithBytes:&filterParams length:sizeof(FilterParams) options:(MTLResourceCPUCacheModeDefaultCache)];
    [_filterParamBuffer setLabel:@"params"];
    
    //TODO animation
}

- (void)onRender:(nonnull KSMetalView *)view
{
   
    dispatch_semaphore_wait(self.displaySemaphore, DISPATCH_TIME_FOREVER);
    [self updateParams];
    view.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1);
    
    //update MVP
     
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    MTLRenderPassDescriptor *passDescriptor = [view getCurrentRenderPassDescriptor];
    assert(passDescriptor != nil);
    
    id<MTLRenderCommandEncoder> renderPass = [commandBuffer renderCommandEncoderWithDescriptor:passDescriptor];
    [renderPass setRenderPipelineState:self.renderPipelineState];
    [renderPass setDepthStencilState:self.depthStencilState];
    [renderPass setFrontFacingWinding:MTLWindingCounterClockwise];
    [renderPass setCullMode:MTLCullModeBack];
    
    const NSUInteger uniformBufferOffset = alignUp(sizeof(KUniform), KSBufferAlignment)*self.bufferIndex;//TODO
    
    [renderPass setVertexBuffer:self.vertexBuffer  offset:0 atIndex:0];
    [renderPass setVertexBuffer:self.uniformBuffer offset:uniformBufferOffset atIndex:1];
    [renderPass setFragmentBuffer:self.filterParamBuffer offset:0 atIndex:2];
    [renderPass setFragmentTexture:_texture atIndex:0];
    
    const MTLIndexType KBEIndexType = MTLIndexTypeUInt16;
    
    [renderPass drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:[self.indexBuffer length]/sizeof(KBEIndex) indexType:KBEIndexType indexBuffer:self.indexBuffer indexBufferOffset:0];
   
    [renderPass endEncoding];
    
    [commandBuffer presentDrawable:view.currentDrawable];
    
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        self.bufferIndex = (self.bufferIndex + 1) % flightBufferCount;
        dispatch_semaphore_signal(self.displaySemaphore);
    }];
    
    [commandBuffer commit];
}

-(id<MTLTexture>)loadTexture: (NSURL *)url
{
    UIImage *image = [UIImage imageNamed:@"nature.jpg"];
    
    //access pixels and invert texture as metal texture starts from top
    assert(image != nil);
    CGImageRef imageRef = [image CGImage];
    //create a suitable bitmap context fro extracting the bits of the image;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    uint8_t *pixels  = (uint8_t *)calloc(height * width * 4, sizeof(uint8_t));
    NSUInteger bytesPerPixel = 4;//TODO;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow,colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    //Flip the context so the +Y points down.
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, CGRectMake(0,0,width,height), imageRef);
    CGContextRelease(context);
    
    
    /*
     A texture descriptor is a lightweigth object that specifies the dimensions and format of a texture.When creating a texture,you provide a texture descriptor and receive an object that conforms to the MTLTexture descriptor(texture type,dimensions,and format) are immutable on ce the texture has benn created ,but still can update the texture as long as the formats match
     */
    
    MTLTextureDescriptor *textDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm width:width height:height mipmapped:NO];
    
    //create texture with descriptor
    id<MTLTexture> texture = [self.device newTextureWithDescriptor:textDesc];
    
    /*
     Setting the data in the texture is also quite simple.Create MTLRegion that represents the entire texture and tell the texture to replace that region with raw image bits  previously retrieved from the context.
     */
    
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    [texture replaceRegion:region mipmapLevel:0 withBytes:pixels bytesPerRow:bytesPerRow];
    
    //TODO do right free pixels.
    
    return texture;
    
}
-(void)updateParams
{
    // filterParams.scaleFactor[0] = 2.0;
    std::unique_lock<std::mutex> lock(filterLock);
    memcpy((uint8_t *)[self.filterParamBuffer contents] ,&filterParams ,sizeof(filterParams));
    
}

-(void)updateMVP:(KSMetalView *)view duration:(NSTimeInterval)duration
{
    /*
     self.time += duration;
     self.rotationx = ;
     float scaleFactor = ;calculate
     const vector_float3 xAxis = {1,0,0};
     const vector_float3 yAxis = {0,1,0};
     const matrix_float4x4 xRot = matrix_float4x4_rotation(xAxis , self.rotationX);
     const matrix_float4x4 yRot = matrix_float4x4_rotation(yAxis, self.rotationY);
     const matrix_float4x4 scale = matrix_float4x4_uniform_scale(scaleFactor);
     const matrix_float4x4 modelMatrix = matrix_multiply(matrix_multiply(xRot,yRot),scale);
     
     const vector_float3 cameraTranslation = {0,0,-5};
     const matrix_float4x4 viewMatrix = matrix_float4x4_translation(cameraTranslation);
     
     const CGSizedrawableSize = view.metalLayer.drawableSize;
     const float spect = drawableSize.widht/drawableSize.height;
     const float fov = (3*M_PI)/5;
     const float near = 1;
     const float far = 100;
     const matrix_float4x4 projectionMatrix = matrix_float4x4_perspective(aspect,fov,near,far);
     
     KUniforms uniforms;
     const NSUInteger uniformBufferOffset = AlignUp(sizeof(KUniforms),KSBufferAlignment) *self.bufferIndex;
     memcpy((uint8_t *)[self.unifromBuffer contents] + uniformBufferOffset,&uniforms ,sizeof(uniforms));
     */
}
-(void)setLogContrastScale:(float)scale
{
    std::unique_lock<std::mutex> lock(filterLock);
    filterParams.scaleFactor[0] = scale;
}
@end

