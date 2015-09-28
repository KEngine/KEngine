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





struct GbufferInOutTerrain{
    float4 pos [[position]];
    float4 normal;
    float4 posWorld;
    float2 textCoord;
    float2 textCoord1;
    float linearDepth;
};






vertex GbufferInOutTerrain gbufferTerrainVertex(const device Vertex* in [[buffer(0)]],const device Uniform& camera [[buffer(1)]],const device Uniform& view [[buffer(3)]],const device Uniform& model [[buffer(2)]],texture2d<float> heightMap [[texture(0)]],unsigned int vid [[vertex_id]]){
    GbufferInOutTerrain out;
    
    
    constexpr sampler defaultSampler(coord::normalized);
    //调整坐标，从［－1，1］－> ［0，1］
    float3 pos = float3(in[vid].pos);
    float2 textCoord = (pos.xz / 250.0) * 0.5 + float2(0.5);
    float2 textCoord1 = float2(in[vid].textCoord);
    //out.textCoord1.x =  4 * (textureCoord.x - 0.25 * (textureCoord.x / 0.25  - trunc(textureCoord.x / 0.25)));
    //out.textCoord1.y =  4 * (textureCoord.y - 0.25 * (textureCoord.y / 0.25  - trunc(textureCoord.y / 0.25)));
    //out.textCoord1.x = fmod(textCoord.x,0.25) * 4;
    //out.textCoord1.y = fmod(textCoord.y,0.25) * 4;

    out.textCoord1 = textCoord1;
    
    /*if (out.textCoord1.x == 0 && fmod(textCoord.x / 0.25,2) == 1){
        out.textCoord1.x = 1.0;
    }
    if (out.textCoord1.y == 0 && fmod(textCoord.y / 0.25,2) == 1){
        out.textCoord1.y = 1.0;
    }*/
    /*if(textCoord.x == 0.75 || textCoord.x == 0.25){
        out.textCoord1.x = 1.0;
    }
    if(textCoord.y == 0.75 || textCoord.y == 0.25){
        out.textCoord1.y = 1.0;
    }
    
    if(textCoord.x == 0.1){
        out.textCoord1.x = 0;
    }
    if(textCoord.y == 0.1){
        out.textCoord1.y = 0;
    }
    //float2 textureCoord1 = textureCoord % float2(0.25,0.25);
    out.textCoord = textCoord;
    //从噪声中获取高度
    float height = heightMap.sample(defaultSampler,textCoord).r * 3;*/

    out.textCoord = textCoord;

    
    out.pos = camera.matrix * view.matrix * model.matrix * float4(float3(pos.x,pos.y,pos.z),1.0);
    out.normal = view.matrix * model.matrix * float4(float3(in[vid].normal),0.0);
    out.posWorld = model.matrix * float4(float3(in[vid].pos),1.0);
    out.linearDepth = (view.matrix * model.matrix * float4(float3(in[vid].pos),1.0)).z;
    
    return out;
    
}


fragment GBufferOut gbufferTerrainFragment(GbufferInOutTerrain in [[stage_in]],texture2d_array<float> terrainTexture [[texture(0)]],texture2d<float> weightTexture [[texture(1)]]){
    GBufferOut out;
    
    
    constexpr sampler defaultSampler;
    float4 grass1 = float4(terrainTexture.sample(defaultSampler,in.textCoord1,0));
    float4 grass2 = float4(terrainTexture.sample(defaultSampler,in.textCoord1,1));
    float4 rock = float4(terrainTexture.sample(defaultSampler,in.textCoord1,2));
    float4 groud = float4(terrainTexture.sample(defaultSampler,in.textCoord1,3));

    //half4 color2 = half4(terrainTexture.sample(defaultSampler,in.textCoord,2));
    half4 weight = half4(weightTexture.sample(defaultSampler,in.textCoord));

    out.pos = in.posWorld;//color 2
    out.normal = in.normal;//color 1
    out.normal.w = in.linearDepth;
       
    /*if(weight){
        out.color = float4(grass1);
    }*/
    float sum = weight.r + weight.g + weight.b + weight.a;
    out.color = float4(groud* weight.r/sum + grass1 * weight.g/sum + rock * weight.b /sum + grass2 * weight.a/sum);
    
    out.light = float4(0,0,0,1);
    return out;
}





