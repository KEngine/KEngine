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

//static constant float sunPos = float4(50,50,50);
//static constant float sunColor = float4(1,1,1,1);


vertex DeferredInOut CompositonVertex(const device VertexPosOnly* in [[buffer(0)]],unsigned int vid [[vertex_id]]){
    DeferredInOut out;
    out.pos =float4(float3(in[vid].pos),1.0);
    return out;
}


fragment half4 CompositionFragment(DeferredInOut in [[stage_in]],GBufferOut gBuffer,constant DirectionLight* lights [[buffer(0)]],constant Uniform& view [[buffer(1)]]){
    half4 color = half4(0,0,0,1);
    float3 vertex_cam = gBuffer.pos.xyz;
    float3 normal_cam = gBuffer.normal.xyz;
    
    float3 camera_cam = float3(0,0,0);
    float4 ambient_color = float4(0,0,0,1.0);//gBuffer.color;
    
    
    float constantAttenuation = 0.5;
    float linearAttenuation = 0;
    float quadraticAttenuation = 0.05;
    
    float4 diffuse_color = float4(0);
    float4 specluar_color = float4(0);
    
    
    //Compute The Sun (lights中的lights[0])
    float shine = lights[0].shine;
    float4 light_color = float4(float3(lights[0].color),1.0);
    float3 light_cam = (view.matrix * float4(float3(lights[0].pos),1.0)).xyz;
    //float3 lightDir = light_cam - vertex_cam;
    //float lightDistance = length(lightDir);
    //lightDir = lightDir / lightDistance;
    //float attenuation = 1.0 / (constantAttenuation + linearAttenuation * lightDistance + quadraticAttenuation * lightDistance * lightDistance);
    
    
    
    float3 n = normalize(normal_cam);
    float3 l = normalize(light_cam);
    float n_dot_l = saturate(dot(n,l));
    diffuse_color += light_color * n_dot_l * materialDiffuse * 1.2;
    
    
    float3 e = normalize(light_cam + camera_cam - vertex_cam);
    float3 r = -l + 2.0 * n_dot_l * n;
    float e_dot_r = saturate(dot(e,r));
    specluar_color += materialSpecular * light_color * pow(e_dot_r,shine);
    
    for (int i = 1 ; i < 5 ; ++i){
        shine = lights[i].shine;
        light_color = float4(float3(lights[i].color),1.0);
        light_cam = (view.matrix * float4(float3(lights[i].pos),1.0)).xyz;
        float3 lightDir = light_cam - vertex_cam;
        float lightDistance = length(lightDir);
        lightDir = lightDir / lightDistance;
        float attenuation = 1 / (constantAttenuation + linearAttenuation * lightDistance + quadraticAttenuation * lightDistance * lightDistance);


    
        n = normalize(normal_cam);
        l = normalize(light_cam);
        n_dot_l = saturate(dot(n,l));
        diffuse_color += light_color * n_dot_l * materialDiffuse * attenuation;
    
    
        e = normalize(light_cam + camera_cam - vertex_cam);
        r = -l + 2.0 * n_dot_l * n;
        e_dot_r = saturate(dot(e,r));
        specluar_color += materialSpecular * light_color * pow(e_dot_r,shine) * attenuation;
    }
    color = half4(ambient_color + diffuse_color + specluar_color);
    return color;

}












