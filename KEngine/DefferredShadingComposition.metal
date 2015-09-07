//
//  DefferredShadingComposition.metal
//  KEngine
//
//  Created by 哈哈 on 15/9/5.
//  Copyright © 2015年 哈哈. All rights reserved.
//

//#include <metal_stdlib>
#include "shaderTypes.h"
using namespace metal;


static constant float4 materialDiffuse = float4(0.4,0.4,0.4,1.0);
static constant float4 materialSpecular = float4(1,1,1,1);


vertex DeferredInOut CompositonVertex(const device VertexPosOnly* in [[buffer(0)]],unsigned int vid [[vertex_id]]){
    DeferredInOut out;
    out.pos =float4(float3(in[vid].pos),1.0);
    return out;
}


fragment half4 CompositionFragment(DeferredInOut in [[stage_in]],GBufferOut gBuffer,constant DirectionLight* lights [[buffer(0)]]){
    half4 color;
    float3 vertex_cam = gBuffer.pos.xyz;
    float4 normal_cam = gBuffer.normal;
    float3 camera_cam = float3(0,0,0);
    float4 ambient_color = gBuffer.color;
    
    
    
    for (int i = 1 ; i < 2 ; ++i){
    float shine = lights[i].shine;
    float3 light_cam = float3(lights[i].pos);
    float4 light_color = float4(float3(lights[i].color),1.0);
    
    
    float3 n = normalize(normal_cam.xyz);
    float3 l = normalize(light_cam + camera_cam - vertex_cam);
    float n_dot_l = saturate(dot(n,l));
    float4 diffuse_color = light_color * n_dot_l * materialDiffuse;
    
    
    float3 e = normalize(camera_cam - vertex_cam);
    float3 r = -l + 2.0 * n_dot_l * n;
    float e_dot_r = saturate(dot(e,r));
    float4 specluar_color = materialSpecular * light_color * pow(e_dot_r,shine);
        color = half4(ambient_color + diffuse_color + specluar_color);
    }
    return color;

}












