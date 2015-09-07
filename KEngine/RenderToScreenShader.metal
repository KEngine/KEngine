//
//  RenderToScreenShader.metal
//  KEngine
//
//  Created by 哈哈 on 15/8/29.
//  Copyright © 2015年 哈哈. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Uniform{
    float4x4 matrix;
};

struct VertexInOut{
    float4  position [[position]];
    //float4  color;
};




struct Vertex{
    packed_float3 pos;
    packed_float3 normal;
};


vertex VertexInOut RenderToScreenVertex(const device Vertex* in [[buffer(0)]],const device Uniform& camera [[buffer(1)]],const device Uniform& model [[buffer(2)]],unsigned int vid [[vertex_id]]){
    VertexInOut out;
    out.position = camera.matrix * model.matrix * float4(float3(in[vid].pos),1.0);

    return out;
}


fragment half4 RenderToScreenFragment(VertexInOut in [[stage_in]]){
    //return half4(1,0,0,1);
    return half4(normalize(in.position));
    
}


