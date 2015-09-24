//
//  RenderToGbuffer.metal
//  KEngine
//
//  Created by 哈哈 on 15/9/4.
//  Copyright © 2015年 哈哈. All rights reserved.
//

//#include <metal_stdlib>
#include "shaderTypes.h"
using namespace metal;



vertex GbufferInOut gbufferVertex(const device Vertex* in [[buffer(0)]],const device Uniform& camera [[buffer(1)]],const device Uniform& view [[buffer(3)]],const device Uniform& model [[buffer(2)]],unsigned int vid [[vertex_id]]){
    GbufferInOut out;
    
    
    out.pos = camera.matrix * view.matrix * model.matrix * float4(float3(in[vid].pos),1.0);
    out.normal = view.matrix * model.matrix * float4(float3(in[vid].normal),0.0);
    out.posWorld = model.matrix * float4(float3(in[vid].pos),1.0);
    out.linearDepth = (view.matrix * model.matrix * float4(float3(in[vid].pos),1.0)).z;
    
    return out;

}


fragment GBufferOut gbufferFragment(GbufferInOut in [[stage_in]]){
    GBufferOut out;
    out.pos = in.posWorld;//color 2
    out.normal = in.normal;//color 1
    out.normal.w = in.linearDepth;
    out.color = float4(0.2,0.2,0.2,1.0); //color 0
    out.light = float4(0,0,0,1);
    return out;
}





