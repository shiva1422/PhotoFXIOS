//
//  KSTextureRenderer.m
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 10/13/23.
//

#import "KSTextureRenderer.h"
#include "Model.h"
#include "memutils.h"

#define flightBufferCount 3

static const uint32_t KSBufferAlignment = 256;

const KTextureModel textModel[]= {
    {.position={1.0f,1.0f,0.0f,1.0f},.UV={1.0f,1.0f}},
    {.position={1.0f,-1.0f,0.0f,1.0f},.UV={1.0f,0.0f}},
    {.position={-1.0f,-1.0f,0.0f,1.0f},.UV={0.0f,0.0f}},
    {.position={-1.0f,1.0f,0.0f,1.0f},.UV={0.0f,1.0f}},
};

const KBEIndex indices[] = {0,2,1,0,3,2};

 
@interface KSTextureRenderer()

@property (strong,nonatomic) id<MTLDevice> device;
@property (strong,nonatomic) id<MTLBuffer> vertexBuffer;
@property (strong,nonatomic) id<MTLBuffer> indexBuffer;
@property (strong,nonatomic) id<MTLBuffer> uniformBuffer;
@property (strong,nonatomic) id<MTLTexture> texture;

@property (strong) id<MTLCommandQueue> commandQueue;
@property (strong) id<MTLRenderPipelineState> renderPipelineState;
@property (strong) id<MTLDepthStencilState> depthStencilState;
@property (strong) dispatch_semaphore_t displaySemaphore;
@property (assign) NSInteger bufferIndex;
@property (assign) float rotationX,rotationY, time;

@end


@implementation KSTextureRenderer

-(instancetype)init
{
    if((self = [super init]))
    {
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
    pipelineDescriptor.vertexFunction = [library newFunctionWithName:@"vert"];
    pipelineDescriptor.fragmentFunction =[library newFunctionWithName:@"frag"];
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
    
    //TODO animation
}

- (void)onRender:(nonnull KSMetalView *)view
{
   
    dispatch_semaphore_wait(self.displaySemaphore, DISPATCH_TIME_FOREVER);
    
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

@end

