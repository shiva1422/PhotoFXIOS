//
//  Texture.metal
//  PhotoFX
//
//  Created by Shiva Shanker Pandiri on 10/13/23.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex
{
    float4 position [[position]];
    float2 UV;
};

struct Uniforms
{
    float4x4 mvpMatrix;
};


vertex Vertex vert(const device Vertex *vertices [[buffer(0)]] , constant Uniforms *uniforms [[buffer(1)]],uint vid[[vertex_id]])
{
    Vertex vout;
    vout.position = vertices[vid].position;
    vout.UV = vertices[vid].UV;
    return vout;
}

fragment float4 frag(Vertex inVertex[[stage_in]] ,texture2d<float>text[[texture(0)]])
{
    constexpr sampler textureSampler(coord::normalized,address::repeat,filter::linear);
    float4 sampledColor = text.sample(textureSampler, inVertex.UV);
   // sampledColor = float4(sampledColor.r)
    return sampledColor;
}
