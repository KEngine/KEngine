//
//  GameUI.swift
//  KEngine
//
//  Created by 哈哈 on 15/10/6.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import Metal
import MetalKit


let aspect:Float = 1920.0 / 1080
//let aspectInverse:Float = 1080.0 / 1920
let UIIndexCount:Int = 6



class GameUI: NSObject {
    var m_scene:GameScene! = nil
    var m_asset:GameActorAsset! = nil
    var m_width:Float = 0
    var m_height:Float = 0
    var m_pos = [Float]()
    var m_vertexBuffer:MTLBuffer! = nil
    var m_indexBuffer:MTLBuffer! = nil
    //var m_quard:[Float]! = nil
    var m_quardHorz:[Float]! = nil
    var m_quardVert:[Float]! = nil

    var m_uiTexture:MTLTexture! = nil
    init(pos:[Float],width:Float,height:Float,scene:GameScene) {
        super.init()
        m_scene = scene
        m_pos = pos
        m_width = width
        m_height = height
        let halfWidth = width / 2
        let halfHeight = height / 2
        m_quardHorz = [
            (m_pos[0] - halfWidth) * aspect,m_pos[1] + halfHeight,0.1,
            (m_pos[0] - halfWidth) * aspect,m_pos[1] - halfHeight,0.1,
            (m_pos[0] + halfWidth) * aspect,m_pos[1] - halfHeight,0.1,
            (m_pos[0] + halfWidth) * aspect,m_pos[1] + halfHeight,0.1,

            
        ]
        
        m_quardVert = [
            m_pos[0] - halfWidth,(m_pos[1] + halfHeight) * aspect,0.1,
            m_pos[0] - halfWidth,(m_pos[1] - halfHeight) * aspect,0.1,
            m_pos[0] + halfWidth,(m_pos[1] - halfHeight) * aspect,0.1,
            m_pos[0] + halfWidth,(m_pos[1] + halfHeight) * aspect,0.1,
            
            
        ]
        
        
        
        m_vertexBuffer = scene.m_device.newBufferWithBytes(m_quardHorz, length: sizeofValue(m_quardHorz[0]) * m_quardHorz.count, options: MTLResourceOptions.CPUCacheModeDefaultCache)
        m_indexBuffer = m_scene.m_render.m_screenQuard.m_indexBuffer
        do{
            m_uiTexture = try m_scene.m_utility.m_textureLoader.newTextureWithContentsOfURL(NSBundle.mainBundle().URLForResource("ak", withExtension: "png")!, options: nil)
        }catch let error as NSError{
            fatalError("Texture Loading Error \(error.localizedDescription)")
        }
        
    }
    
    func renderUI(encoder:MTLRenderCommandEncoder){
        encoder.setVertexBuffer(m_vertexBuffer, offset: 0, atIndex: 0)
        encoder.setFragmentTexture(m_uiTexture, atIndex: 0)
        encoder.setRenderPipelineState(m_scene.m_render.m_renderUIPipelineState)
        encoder.drawIndexedPrimitives(MTLPrimitiveType.Triangle, indexCount:UIIndexCount,indexType: MTLIndexType.UInt16, indexBuffer: m_indexBuffer, indexBufferOffset: 0)

        
    }
    
    
    
    func changeSize(aspect:Float){
        print("Change Size")
        
        
        /*m_quard[0] = m_quard[0] * aspect
        m_quard[3] = m_quard[3] * aspect
        m_quard[6] = m_quard[6] * aspect
        m_quard[9] = m_quard[9] * aspect*/
        
        if aspect > 1{
            memcpy(m_vertexBuffer.contents(), m_quardHorz, sizeofValue(m_quardHorz[0]) * m_quardHorz.count)

        }else{
            memcpy(m_vertexBuffer.contents(), m_quardVert, sizeofValue(m_quardVert[0]) * m_quardVert.count)

        }
        
    }
    
    
    
    
    
    
    
    
    
        
}