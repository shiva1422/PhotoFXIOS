//
//  Model.h
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 10/13/23.
//

#ifndef Model_h
#define Model_h
#include <simd/simd.h>

////elementerBuffer Index
typedef uint16_t KBEIndex;

//Metal texture starts at top
typedef struct {
    
    vector_float4 position;
    vector_float2 UV;
    
}KTextureModel;


typedef struct{
    
    matrix_float4x4 mvpMatrix;
    
}KUniform;

#endif /* Model_h */
