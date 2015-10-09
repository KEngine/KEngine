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

static constant float4 materialSpecular = float4(1,1,1,1);
static constant float4 materialDiffuse = float4(0.4,0.4,0.4,1);

//static constant float sunPos = float4(50,50,50);
//static constant float sunColor = float4(1,1,1,1);


vertex DeferredInOut CompositonVertex(const device VertexPosOnly* in [[buffer(0)]],unsigned int vid [[vertex_id]]){
    DeferredInOut out;
    out.pos = float4(in[vid].pos,1.0);
    return out;
}


fragment GBufferOut CompositionFragment(DeferredInOut in [[stage_in]],GBufferOut gBuffer,constant DirectionLight* lights [[buffer(0)]],constant Uniform& view [[buffer(1)]],constant Uniform& sunProjection [[buffer(2)]],constant Uniform& sunView [[buffer(3)]],texture2d<float> shadowMap [[texture(0)]]){
    //half4 color = half4(0,0,0,1);
    float3 vertex_cam = (view.matrix * gBuffer.pos).xyz;
    float3 normal_cam = gBuffer.normal.xyz;
    
    float4 ambient_color = float4(0.15,0.15,0.15,1);
    
    
    
    float4x4 bais;
    bais[0] = float4( 0.5,   0   ,    0, 0);
    bais[1] = float4( 0  ,  -0.5 ,    0, 0);
    bais[2] = float4( 0  ,   0   ,    1, 0);
    bais[3] = float4(0.5 ,   0.5 ,    0, 1);
    //constexpr sampler shadow_sampler(coord::normalized, filter::linear, address::clamp_to_edge, compare_func::less);
    //float2 texelSize = float2(1 / 1024.0,1 / 1024.0);
    float4 shadowcoord = bais *  sunProjection.matrix * sunView.matrix * gBuffer.pos;
    
    
    
    //PCSS 硬件无法支撑  5x5倍采样，fps由 60fps->20fps,该用vsm
    /*float result = 0.0;
    for(float y = -2.0 ; y <= 2.0 ; y += 1.0){
        for(float x = -2.0 ; x <= 2.0 ; x += 1.0){
            float2 coordOffset = float2(x,y) * texelSize;
            result += shadowMap.sample_compare(shadow_sampler, shadowcoord.xy/shadowcoord.w + coordOffset ,shadowcoord.z/shadowcoord.w);
        }
    }
    result = result / 25.0;*/
    
    
    
    //float shadow = shadowMap.sample_compare(shadow_sampler, shadowcoord.xy/shadowcoord.w ,shadowcoord.z/shadowcoord.w);
    constexpr sampler s(coord::normalized,filter::linear,address::clamp_to_edge,filter::linear);
    
    float2 moments = shadowMap.sample(s,shadowcoord.xy/shadowcoord.w).xy;
    float p = step(shadowcoord.z,moments.x);
    float variance = max(moments.y - moments.x * moments.x,0.9999);
    
    float d = shadowcoord.z - moments.x;
    float pMax = variance /(variance + d*d);
    
    //float pMax = clamp((v - 0.4)/(1.0 - v),0.4,1.0);
    
    float shadow = min(1.0,max(p,pMax));
    
    
    float4 diffuse_color = float4(0);
    float4 specluar_color = float4(0);
    
    
    //Compute The Sun (lights中的lights[0])
    float shine = lights[0].shine;
    float4 light_color = float4(float3(lights[0].color),1.0);
    float3 light_cam = (view.matrix * float4(float3(lights[0].pos),1.0)).xyz;
    
    float3 n = normalize(normal_cam);
    float3 l = normalize(light_cam);
    float n_dot_l = saturate(dot(n,l));
    diffuse_color += light_color * n_dot_l * gBuffer.color * 1.2 * shadow ;
    
    
    float3 e = normalize(light_cam  - vertex_cam);
    float3 r = -l + 2.0 * n_dot_l * n;
    float e_dot_r = saturate(dot(e,r));
    specluar_color += materialSpecular * light_color * pow(e_dot_r,shine) * shadow;
        
    diffuse_color += gBuffer.light * materialDiffuse;
    specluar_color += gBuffer.light *materialSpecular;
    
    //color = half4(ambient_color + diffuse_color + specluar_color);
    //return color;
    //return half4(gBuffer.light);
    gBuffer.color = ambient_color + diffuse_color + specluar_color;
    return gBuffer;
}












