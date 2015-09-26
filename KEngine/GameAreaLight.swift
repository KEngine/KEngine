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
    var m_pos:[Float]! = nil //!!!!!目前还没有实现动态  暂时以静态处理
    var m_color:[Float]! = nil
    var m_lightInfoBuffer:GameUniformBuffer! = nil
    
    var m_ball:GameActor! = nil

    
    init(vertex:[Float],index:[UInt16],pos:[Float],color:[Float],scene:GameScene) {
        super.init()
        m_asset = GameActorAsset(vertices: vertex, indices: index, primitiveType: MTLPrimitiveType.Triangle, device: scene.m_device)
        m_pos = pos
        m_color = color
        m_lightInfoBuffer = GameUniformBuffer(data: [m_pos[0],m_pos[1],m_pos[2],m_color[0],m_color[1],m_color[2]], scene: scene)

        m_modelMatrix.translate(pos[0], y: pos[1], z : pos[2])
        m_modelMatrix.scale(10)

        m_modelBuffer = GameUniformBuffer(data: m_modelMatrix.dumpToSwift(), scene: scene)
        m_ball = GameActor(vertices: ball_vertices, indices: ball_indices, pos: m_pos, scene: scene)
        scene.m_light.append(self)
    }
    
    
    func renderWithPipelineStates(encoder: MTLRenderCommandEncoder,pipelineState:MTLRenderPipelineState,depthState:MTLDepthStencilState) {
        encoder.setVertexBuffer(m_asset.vertexBuffer(), offset: 0, atIndex: 0)
        encoder.setVertexBuffer(m_modelBuffer.buffer(), offset: 0, atIndex: 3)
        encoder.setVertexBuffer(m_lightInfoBuffer.buffer(), offset: 0, atIndex: 4)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setDepthStencilState(depthState)
        encoder.drawIndexedPrimitives(m_asset.m_primitiveType, indexCount: m_asset.m_indices.count, indexType: MTLIndexType.UInt16, indexBuffer: m_asset.m_indexBuffer, indexBufferOffset: 0)
    }
}