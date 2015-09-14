//
//  Math.swift
//  KEngine
//
//  Created by 哈哈 on 15/8/27.
//  Copyright © 2015年 哈哈. All rights reserved.
//
import Foundation
import MetalKit
import simd




extension float4x4{
    
    mutating func matrixFromPerspectiveFOV(fovY:Float,aspect:Float,nearZ:Float,farZ:Float){
        self = float4x4(0)
        let yScale:Float = 1.0 / tanf(fovY * Float(0.5))
        let xScale:Float = yScale / aspect
        let q = farZ / (farZ - nearZ)
        
        self[0][0] = xScale
        self[1][1] = yScale
        self[2][2] = q
        self[2][3] = 1
        self[3][2] = -q * nearZ
        
    }
    
    
    
    mutating func MatrixMakeFrustum_oc(left:Float,right:Float,bottom:Float,top:Float,near:Float,far:Float){
        self = float4x4(0)
        let width:Float = right - left
        let height:Float = top - bottom
        let depth : Float = far - near
        let sDepth :Float = far / depth
        self[0][0] = width
        self[1][1] = height
        self[2][2] = sDepth
        self[2][3] = 1
        self[3][2] = -sDepth * near
    }
    
    mutating func MatrixMakeOrtho2D_OC(left:Float,right:Float,bottom:Float,top:Float,near:Float,far:Float){
        self = float4x4(0)
        let sLength = 1.0 / (right - left)
        let sHeight = 1.0 / (top - bottom)
        let sDepth = 1.0 / (far - near)
        
        self[0][0] = 2.0 * sLength
        self[1][1] = 2.0 * sHeight
        self[2][2] = sDepth
        
        self[3][0] = -sLength * (left + right)
        self[3][1] = -sHeight * (top + bottom)
        self[3][2] = -sDepth * near
        self[3][3] = 1.0
    }
    
    mutating func matrixFromLookAt(eye:[Float],center:[Float],up:[Float]){
        
        let zAxis = normalize(float3(center) - float3(eye))
        let xAxis = normalize(cross(float3(up), zAxis))
        let yAxis = cross(zAxis, xAxis)
        
        self[0][0] = xAxis[0]
        self[0][1] = yAxis[0]
        self[0][2] = zAxis[0]
        self[0][3] = 0
        
        self[1][0] = xAxis[1]
        self[1][1] = yAxis[1]
        self[1][2] = zAxis[1]
        self[1][3] = 0.0
        
        
        self[2][0] = xAxis[2]
        self[2][1] = yAxis[2]
        self[2][2] = zAxis[2]
        self[2][3] = 0
        
        self[3][0] = -dot(xAxis,float3(eye))
        self[3][1] = -dot(yAxis,float3(eye))
        self[3][2] = -dot(zAxis,float3(eye))
        self[3][3] = 1.0
    }
    
    
    
    mutating func matrixFromOrtho2d(left:Float,right:Float,bottom:Float,top:Float,near:Float,far:Float){
        self = float4x4(0)
        let sLenght = 1.0 / (right - left)
        let sHeight = 1.0 / (top - bottom)
        let sDepth = 1.0 / (far - near)
        
        self[0][0] = 2 * sLenght
        
        self[1][1] = 2 * sHeight
        
        self[2][2] = sDepth
        
        self[3][2] = -near * sDepth
        self[3][3] = 1.0
    }
    
    
    
    
    
    func matrixFromScale(size:Float)->float4x4{
        var result = float4x4(1)
        result[0][0] = size
        result[1][1] = size
        result[2][2] = size
        return result
    }
    
    
    func matrixFromTranslation(x:Float,y:Float,z:Float)->float4x4{
        var result = float4x4(1)
        result[3] = [x,y,z,1]
        return result
    }
    func matrixFromRotation(radians:Float,axis:[Float])->float4x4{
        var result = float4x4(1)
        let v = normalize(float3(axis))
        let cos = cosf(radians)
        let cosp = 1 - cos
        let sin = sinf(radians)
        
        result[0] = [
            cos + cosp * v.x * v.x,
            cosp * v.x * v.y + v.z * sin,
            cosp * v.x * v.z - v.y * sin,
            0.0
        ]
        result[1] = [
            cosp * v.x * v.y - v.z * sin,
            cos + cosp * v.y * v.y,
            cosp * v.y * v.z + v.x * sin,
            0.0
        ]
        result[2] = [
            cosp * v.x * v.z + v.y * sin,
            cosp * v.y * v.z - v.x * sin,
            cos + cosp * v.z * v.z,
            0.0
        ]
        
        result[3] = [0, 0.0, 0.0, 1.0]
        return result
    }
    mutating func rotate(radians:Float,axis:[Float]){
        self = self * matrixFromRotation(radians, axis: axis)
    }
    
    mutating func translate(x:Float,y:Float,z:Float){
        self = self * matrixFromTranslation(x, y: y, z: z)
    }
    mutating func scale(scale:Float){
        self = self * matrixFromScale(scale)
    }
    
    
    
    
    
    
    
    
    func dumpToSwift()->[Float]{
        return [
            self[0][0],self[0][1],self[0][2],self[0][3],
            self[1][0],self[1][1],self[1][2],self[1][3],
            self[2][0],self[2][1],self[2][2],self[2][3],
            self[3][0],self[3][1],self[3][2],self[3][3],
        ]
    }
}
