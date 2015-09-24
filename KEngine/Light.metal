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
    float4 lightPos;
    float4 color;
};


struct LightUniform{
    packed_float3 pos;
    packed_float3 color;
};

vertex LightInOut lightVertex(const device Vertex* in [[buffer(0)]],const device Uniform& camera [[buffer(1)]],const device Uniform& view [[buffer(2)]],const device Uniform& model [[buffer(3)]],const device LightUniform& lightInfo [[buffer(4)]],unsigned int vid [[vertex_id]]){
    LightInOut out;
    out.lightPos = float4(float3(lightInfo.pos),1.0);
    out.pos = camera.matrix * view.matrix * model.matrix * float4(float3(in[vid].pos),1.0);
    out.color = float4(float3(lightInfo.color),1.0);
    
    return out;
}

/*constant Uniform& view [[buffer(1)]],constant Uniform& sunProjection [[buffer(2)]],constant Uniform& sunView [[buffer(3)]]*/
fragment GBufferOut lightFragment(LightInOut in [[stage_in]],GBufferOut gbuffer,constant Uniform& view [[buffer(1)]]){
        //gbuffer.light = float4(0,0,1,1);
    float3 n_s = gbuffer.normal.rgb;
    float scene_z = gbuffer.normal.a;
    float3 n = n_s * 2.0 - 1.0;
    float3 v_view = ((view.matrix * gbuffer.pos).xyz);
    float3 v = v_view * (scene_z / v_view.z);
    
    float3 l = (view.matrix * in.lightPos).xyz - v;
    
    
    
    float n_ls = dot(n, n);
    float v_ls = dot(v, v);
    float l_ls = dot(l, l);
    float3 h = (l * rsqrt(l_ls / v_ls) - v);
    float h_ls = dot(h, h);
    float nl = dot(n, l) * rsqrt(n_ls * l_ls);
    float nh = dot(n, h) * rsqrt(n_ls * h_ls);
    float d_atten = sqrt(l_ls);
    float atten = fmax(1.0 - d_atten / 10, 0.0);
    float diffuse = fmax(nl, 0.0) * atten;
    
    float4 light = gbuffer.light;
    light.rgb += float3(in.color)* diffuse;
    light.a += pow(fmax(nh, 0.0), 32.0) * step(0.0, nl) * atten * 1.0001;
    
    GBufferOut output;
    output.color = gbuffer.color;
    output.normal = gbuffer.normal;
    output.pos = gbuffer.pos;
    output.light = light;
    
    return output;
    
    //return out;

}


/*GBufferOut out;
 out.color = gbuffer.color;
 out.normal = gbuffer.normal;
 out.pos = gbuffer.pos;
 //gbuffer.light = in.color;
 //gbuffer.color = float4(1,1,0,1);
 
 float constantAttenuation = 0.0001;
 float linearAttenuation = 0;
 float quadraticAttenuation = 0.0001;
 
 float3 vertex_cam = (view.matrix * gbuffer.pos).xyz;
 float3 light_cam = (view.matrix * float4(float3(in.lightPos),1.0)).xyz;
 float3 lightDir = light_cam - vertex_cam;
 float lightDistance = length(lightDir);
 lightDir = lightDir / lightDistance;
 float attenuation = 1 / (constantAttenuation + linearAttenuation * lightDistance + quadraticAttenuation * lightDistance * lightDistance);
 
 float3 normal_cam = gbuffer.normal.xyz;
 
 
 
 
 float shine = 50;
 float4 light_color = in.color;
 float3 n = normalize(normal_cam);
 float3 l = normalize(light_cam);
 float n_dot_l = saturate(dot(n,l));
 float4 diffuse_color = light_color * n_dot_l * attenuation;
 
 
 float3 e = normalize(light_cam - vertex_cam);
 float3 r = -l + 2.0 * n_dot_l * n;
 float e_dot_r = saturate(dot(e,r));
 float4 specluar_color = light_color * pow(e_dot_r,shine) * attenuation;
 out.light = diffuse_color + specluar_color;
*/
