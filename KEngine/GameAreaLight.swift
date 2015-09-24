//
//  GameAreaLight.swift
//  KEngine
//
//  Created by 哈哈 on 15/9/24.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import Metal
import simd



class GameAreaLight: NSObject{
    var m_asset:GameActorAsset! = nil
    var m_modelBuffer:GameUniformBuffer! = nil
    var m_modelMatrix = float4x4(1)

    
    init(vertex:[Float],index:[UInt16],pos:[Float],scene:GameScene) {
        super.init()
        m_asset = GameActorAsset(vertices: vertex, indices: index, primitiveType: MTLPrimitiveType.Triangle, device: scene.m_device)
        m_modelMatrix.translate(pos[0], y: pos[1], z : pos[2])
        m_modelBuffer = GameUniformBuffer(data: m_modelMatrix.dumpToSwift(), scene: scene)
        scene.m_light.append(self)
    }
    
    
    func renderWithPipelineStates(encoder: MTLRenderCommandEncoder,pipelineState:MTLRenderPipelineState,depthState:MTLDepthStencilState) {
        encoder.setVertexBuffer(m_asset.vertexBuffer(), offset: 0, atIndex: 0)
        encoder.setVertexBuffer(m_modelBuffer.buffer(), offset: 0, atIndex: 3)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setDepthStencilState(depthState)
        encoder.drawIndexedPrimitives(m_asset.m_primitiveType, indexCount: m_asset.m_indices.count, indexType: MTLIndexType.UInt16, indexBuffer: m_asset.m_indexBuffer, indexBufferOffset: 0)
    }
}