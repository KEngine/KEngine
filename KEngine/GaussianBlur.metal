//
//  GaussianBlur.metal
//  KEngine
//
//  Created by 哈哈 on 15/9/22.
//  Copyright © 2015年 哈哈. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


kernel void GaussianBlur(
                        texture2d<float,access::read>  inputImage  [[ texture(0) ]],
                        texture2d<float,access::write>  outputImage  [[ texture(1) ]],
                        uint2 gid [[ thread_position_in_grid]])

{
    
    float4 result = float4(0.0);
    float2 texlSize = float2(1.0/1024.0,1.0/1024.0);
    
    /*result += inputImage.read(uint2(gid.x + 1,gid.y + 1));
    result += inputImage.read(uint2(gid.x + 1,gid.y + 0));
    result += inputImage.read(uint2(gid.x + 1,gid.y + -1));
    
    
    result += inputImage.read(uint2(gid.x ,gid.y + 1));
    result += inputImage.read(uint2(gid.x ,gid.y + 0));
    result += inputImage.read(uint2(gid.x ,gid.y + -1));

    
    
    result += inputImage.read(uint2(gid.x - 1,gid.y + 1));
    result += inputImage.read(uint2(gid.x - 1,gid.y + 0));
    result += inputImage.read(uint2(gid.x - 1,gid.y + -1));*/
    
    for (int i = -1 ; i <= 1 ; i++){
        for (int j = -1 ; j <= 1 ; j++){
            result += inputImage.read(uint2(gid.x + i * texlSize.x ,gid.y + j + texlSize.y));
        }
    }



    
    
    
    result = result / 9.0;

    
    
    outputImage.write(result,gid);
}









