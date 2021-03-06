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
    var m_scene:GameScene! = nil
    
    
    var m_buffer:MTLBuffer! = nil
    var m_buffer1:MTLBuffer! = nil
    var m_buffer2:MTLBuffer! = nil
    
    
    init(data:[Float],scene:GameScene) {
        super.init()
        m_data = data
        m_scene = scene
        m_buffer = scene.m_device.newBufferWithBytes(m_data, length: sizeofValue(m_data[0]) * m_data.count, options: MTLResourceOptions.CPUCacheModeDefaultCache)
        m_buffer1 = scene.m_device.newBufferWithBytes(m_data, length: sizeofValue(m_data[0]) * m_data.count, options: MTLResourceOptions.CPUCacheModeDefaultCache)
        m_buffer2 = scene.m_device.newBufferWithBytes(m_data, length: sizeofValue(m_data[0]) * m_data.count, options: MTLResourceOptions.CPUCacheModeDefaultCache)
    

    }
    
    func copyDataToBuffer(){
        memcpy(self[m_scene.m_render.m_currentIndex].contents(), m_data, sizeofValue(m_data[0]) * m_data.count)
    }
    
    
    func updateBuffer(data:[Float]){
        if data.count == m_data.count{
            m_data = data
        }else{
            print("Buffer Cannot Update,Buffer Data Length Not Match")
        }
    }
    
    func buffer()->MTLBuffer{
        copyDataToBuffer()
        return self[m_scene.m_render.m_currentIndex]
    }
    
    subscript(i:Int)->MTLBuffer{
        get{
            if i == 0 {
                return m_buffer
            }else if i == 1{
                return m_buffer1
            }else{
                return m_buffer2
            }
        }
    
    }
    
}