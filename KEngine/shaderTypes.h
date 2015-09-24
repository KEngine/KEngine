//
//  shaderTypes.h
//  KEngine
//
//  Created by 哈哈 on 15/9/4.
//  Copyright © 2015年 哈哈. All rights reserved.
//

#ifndef shaderTypes_h
#define shaderTypes_h



#include <metal_stdlib>
using namespace metal;

struct VertexPosOnly{
    packed_float3 pos;
};





struct DirectionLight{
    //float data[];
    packed_float3 pos;
    packed_float3 color;
    float shine;
};


struct DeferredInOut{
    float4 pos [[position]];
};


struct GBufferOut{
    float4 color  [[color(0)]];
    float4 normal [[color(1)]];
    float4 pos    [[color(2)]];
    float4 light  [[color(3)]];

};



struct Uniform{
    float4x4 matrix;
};


struct Vertex{
    packed_float3 pos;
    packed_float3 normal;
};



struct GbufferInOut{
    float4 pos [[position]];
    float4 normal;
    float4 posWorld;
    float linearDepth;
};









#endif /* shaderTypes_h */
