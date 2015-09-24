//
//  Light.metal
//  KEngine
//
//  Created by 哈哈 on 15/9/24.
//  Copyright © 2015年 哈哈. All rights reserved.
//

#include <metal_stdlib>
#include "shaderTypes.h"
using namespace metal;

struct LightInOut{
    float4 pos [[position]];
}

vertex LightInOut lightVertex(const device Vertex* in [[buffer(0)]],const device Uniform& camera [[buffer(1)]],const device Uniform& view [[buffer(2)]],const device Uniform& model [[buffer(3)]],unsigned int vid [[vertex_id]]){
    LightInOut out;
    out.pos = camera.matrix * view.matrix * model.matrix * float4(float3(in[vid].pos),1.0);

}


fragment float4 lightFragment(LightInOut in [[stage_in]],GBufferOut gbuffer){

}
