//
//  RenderUI.metal
//  KEngine
//
//  Created by 哈哈 on 15/10/6.
//  Copyright © 2015年 哈哈. All rights reserved.
//

#include <metal_stdlib>
#include "shaderTypes.h"
using namespace metal;


//Vertex使用composition 中的vertex

struct UIInOut{
    float4 pos [[position]];
    float2 textCoord;
};


vertex UIInOut RenderUIVertex(const device VertexPosOnly* in [[buffer(0)]],const device packed_float2* textCoord [[buffer(1)]],unsigned int vid [[vertex_id]]){
    UIInOut out;
    out.pos = float4(in[vid].pos,1.0);
    out.textCoord = float2(textCoord[vid]);
    return out;
}


fragment half4 RenderUIFragment(UIInOut in [[stage_in]],texture2d<float> uiTexture [[texture(0)]]){
    
    constexpr sampler defaultSampler;
    //float4 grass1 = float4(terrainTexture.sample(defaultSampler,in.textCoord1,0));
    
    return half4(uiTexture.sample(defaultSampler,in.textCoord));
}

