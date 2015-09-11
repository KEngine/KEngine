//
//  GameActor.swift
//  KEngine
//
//  Created by 哈哈 on 15/8/27.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import Metal
import MetalKit



class GameActor:NSObject,GameRenderDelegate{
    var m_asset:GameActorAsset! = nil
    var m_scene:GameScene! = nil
    //var m_renderPipelineState:MTLRenderPipelineState! = nil
    //var m_depthState:MTLDepthStencilState! = nil
    var m_modelBuffer:GameUniformBuffer! = nil
    var m_modelMatrix = float4x4(1)
    init(vertices:[Float],indices:[UInt16],scene:GameScene) {
        super.init()
        m_scene = scene
        m_asset = GameActorAsset(vertices: vertices, indices: indices,primitiveType:MTLPrimitiveType.Triangle,device:m_scene.m_device)
        
        m_modelBuffer = GameUniformBuffer(data: m_modelMatrix.dumpToSwift(), scene: scene)

        m_scene.m_actor.append(self)
    }
    
    func updateModel(){
        m_modelBuffer.updateBuffer(m_modelMatrix.dumpToSwift())
    }
    
    
    func translate(x:Float,y:Float,z:Float){
        m_modelMatrix.translate(x, y: y, z: z)
        updateModel()
    }
    
    func rotate(radians:Float,axis:[Float]){
        m_modelMatrix.rotate(radians, axis: axis)
        updateModel()
    }
    
    
    
    
    
    func renderWithPipelineStates(encoder: MTLRenderCommandEncoder,pipelineState:MTLRenderPipelineState,depthState:MTLDepthStencilState) {
        encoder.setVertexBuffer(m_scene.m_utility.m_camera.projectionBuffer(), offset: 0, atIndex: 1)
        encoder.setVertexBuffer(m_scene.m_utility.m_camera.viewBuffer(), offset: 0, atIndex: 3)
        encoder.setVertexBuffer(m_asset.vertexBuffer(), offset: 0, atIndex: 0)
        encoder.setVertexBuffer(m_modelBuffer.buffer(), offset: 0, atIndex: 2)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setDepthStencilState(depthState)
        encoder.drawIndexedPrimitives(m_asset.m_primitiveType, indexCount: m_asset.m_indices.count, indexType: MTLIndexType.UInt16, indexBuffer: m_asset.m_indexBuffer, indexBufferOffset: 0)
    }
    
    
    
    
    
}