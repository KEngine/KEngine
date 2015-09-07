//
//  GameUniformBuffer.swift
//  KEngine
//
//  Created by 哈哈 on 15/8/30.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import Metal
import MetalKit



class GameUniformBuffer: NSObject {
    var m_data:[Float]! = nil
    var m_buffer:MTLBuffer! = nil
    
    
    init(data:[Float],scene:GameScene) {
        super.init()
        m_data = data
        m_buffer = scene.m_device.newBufferWithBytes(m_data, length: sizeofValue(m_data[0]) * m_data.count, options: MTLResourceOptions.CPUCacheModeDefaultCache)
    }
    
    func updateBuffer(){
        memcpy(m_buffer.contents(), m_data, sizeofValue(m_data[0]) * m_data.count)
    }
    
    
    func updateBuffer(data:[Float]){
        if data.count == m_data.count{
            m_data = data
            updateBuffer()
        }else{
            print("Buffer Cannot Update,Buffer Data Length Not Match")
        }
    }
    
    func buffer()->MTLBuffer{
        return m_buffer
    }
}