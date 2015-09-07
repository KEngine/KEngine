//
//  GameActorAsset.swift
//  KEngine
//
//  Created by 哈哈 on 15/8/28.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import Metal



enum BufferIndex:Int{
    case VERTEX = 0,INDEX = 1
}


struct GameActorAsset{
    
    var m_vertices:[Float]! = nil
    var m_indices:[UInt16]! = nil
    var m_vertexBuffer:MTLBuffer! = nil
    var m_indexBuffer:MTLBuffer! = nil
    var m_primitiveType:MTLPrimitiveType! = nil
    
    init(vertices:[Float],indices:[UInt16],primitiveType:MTLPrimitiveType,device:MTLDevice){
        m_primitiveType = primitiveType
        //vertex and its buffer
        m_vertices = vertices
        m_vertexBuffer = device.newBufferWithBytes(vertices, length: sizeofValue(vertices[0]) * vertices.count, options: MTLResourceOptions.CPUCacheModeDefaultCache)
        //index and its buffer
        m_indices = indices
        m_indexBuffer = device.newBufferWithBytes(indices, length: sizeofValue(indices[0]) * indices.count, options: MTLResourceOptions.CPUCacheModeDefaultCache)
        
    }
    
    func vertexBuffer()->MTLBuffer{
        return m_vertexBuffer
    }
    func indexBuffer()->MTLBuffer{
        return m_indexBuffer
    }
}