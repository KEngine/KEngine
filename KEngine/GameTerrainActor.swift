//
//  GameTerrainActor.swift
//  KEngine
//
//  Created by 哈哈 on 15/9/23.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import Metal
import simd



class GameTerrainActor:GameActor {
    var m_grid:GameGrid! = nil
    var m_heightMap:MTLTexture! = nil
    var m_geometryPipelineState:MTLRenderPipelineState! = nil
    var m_geometryDepthStencilState:MTLDepthStencilState! = nil
    var m_textureArray:GameTextureArray! = nil
    init(scene:GameScene,m0:float2,m1:float2,m2:float2,m3:float2,depth:Int) {
        m_grid = GameGrid(m0: m0, m1: m1, m2: m2, m3: m3, depth: depth)
        super.init(vertices: m_grid.m_vertex, indices: m_grid.m_index, pos: [0,0,0], scene: scene)
        do{
            m_heightMap = try m_scene.m_utility.m_textureLoader.newTextureWithContentsOfURL(NSBundle.mainBundle().URLForResource("heightmap", withExtension: "png")!, options: nil)
        }catch let error as NSError{
            fatalError(error.localizedDescription)
        }
        setupGeometryState()
        m_textureArray = GameTextureArray(textureFilePaths: ["grass","ground","weight"], scene: m_scene)
    }
    
    func setupGeometryState(){
        let renderPipelineDesc = m_scene.m_utility.m_descriptor.m_renderPipelineDesc
        renderPipelineDesc.vertexFunction = m_scene.m_render.m_library.newFunctionWithName("gbufferTerrainVertex")
        renderPipelineDesc.fragmentFunction = m_scene.m_render.m_library.newFunctionWithName("gbufferTerrainFragment")
        
        
        renderPipelineDesc.colorAttachments[0].pixelFormat = m_scene.m_mtkView.colorPixelFormat
        renderPipelineDesc.colorAttachments[1].pixelFormat = MTLPixelFormat.RGBA16Float
        renderPipelineDesc.colorAttachments[2].pixelFormat = MTLPixelFormat.RGBA16Float
        renderPipelineDesc.colorAttachments[3].pixelFormat = MTLPixelFormat.RGBA16Float
        //m_scene.m_mtkView.colorPixelFormat
        //renderPipelineDesc.colorAttachments[3].pixelFormat = m_scene.m_mtkView.colorPixelFormat
        
        
        renderPipelineDesc.depthAttachmentPixelFormat = MTLPixelFormat.Depth32Float_Stencil8
        renderPipelineDesc.stencilAttachmentPixelFormat = MTLPixelFormat.Depth32Float_Stencil8
        
        do{
            m_geometryPipelineState = try m_scene.m_device.newRenderPipelineStateWithDescriptor(renderPipelineDesc)
        }catch let error as NSError{
            print("(GameDefferedRender.swift setupGeometryState() function) :\(error.localizedDescription),\(error.localizedRecoverySuggestion)")
        }
        
        
        let depthStencilDesc = m_scene.m_utility.m_descriptor.m_depthDesc
        let stencilState = m_scene.m_utility.m_descriptor.m_stencilDesc
        depthStencilDesc.depthWriteEnabled = true
        depthStencilDesc.depthCompareFunction = MTLCompareFunction.LessEqual
        stencilState.stencilCompareFunction = MTLCompareFunction.Always
        stencilState.stencilFailureOperation = MTLStencilOperation.Keep
        stencilState.depthFailureOperation = MTLStencilOperation.Keep
        stencilState.depthStencilPassOperation = MTLStencilOperation.Replace
        stencilState.readMask = 0xFF
        stencilState.writeMask = 0xFF
        depthStencilDesc.frontFaceStencil = stencilState
        depthStencilDesc.backFaceStencil = stencilState
        
        
        m_geometryDepthStencilState = m_scene.m_device.newDepthStencilStateWithDescriptor(depthStencilDesc)
    }
    
    
    override func renderWithPipelineStates(encoder: MTLRenderCommandEncoder, pipelineState: MTLRenderPipelineState, depthState: MTLDepthStencilState) {
        encoder.setVertexBuffer(m_asset.vertexBuffer(), offset: 0, atIndex: 0)
        encoder.setFragmentTexture(m_textureArray.m_texture2DArray, atIndex: 0)
        encoder.setVertexBuffer(m_modelBuffer.buffer(), offset: 0, atIndex: 2)
        encoder.setVertexTexture(m_heightMap, atIndex: 0)
        encoder.setRenderPipelineState(m_geometryPipelineState)
        encoder.setDepthStencilState(m_geometryDepthStencilState)
        encoder.drawIndexedPrimitives(m_asset.m_primitiveType, indexCount: m_asset.m_indices.count, indexType: MTLIndexType.UInt16, indexBuffer: m_asset.m_indexBuffer, indexBufferOffset: 0)
        
    }
}