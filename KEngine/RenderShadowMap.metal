//
//  RenderShadowMap.metal
//  KEngine
//
//  Created by 哈哈 on 15/9/13.
//  Copyright © 2015年 哈哈. All rights reserved.
//

#include <metal_stdlib>
#include "shaderTypes.h"
using namespace metal;


struct ShadowOutPut
{
    float4 pos [[position]];
};



vertex ShadowOutPut renderShadowMapVertex(const device Vertex* in [[buffer(0)]],const device Uniform& camera [[buffer(1)]],const device Uniform& view [[buffer(3)]],const device Uniform& model [[buffer(2)]],unsigned int vid [[vertex_id]]){
    ShadowOutPut out;
    out.pos = camera.matrix * view.matrix * model.matrix * float4(float3(in[vid].pos),1.0);
    return out;
}


fragment float4 renderShadowMapFragment(ShadowOutPut in [[stage_in]]){
    //return in.pos.z/in.pos.w;
    float depth = in.pos.z/in.pos.w;
    //float4 color = float4(0,1,0,1);
    float4 color = float4(depth,depth,depth,1);
    return color;
}





