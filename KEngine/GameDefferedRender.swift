//
//  GameDefferedRender.swift
//  KEngine
//
//  Created by 哈哈 on 15/9/3.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import Metal
import MetalKit


protocol GameRenderDelegate{
    func renderWithPipelineStates(encoder:MTLRenderCommandEncoder,pipelineState:MTLRenderPipelineState,depthState:MTLDepthStencilState)
}



class GameDefferedRender: NSObject,MTKViewDelegate {
    
    var m_scene:GameScene! = nil
    var m_sizeChanged:Bool = false
    var m_size:CGSize! = nil
    var m_library:MTLLibrary! = nil
    var m_commandQueue:MTLCommandQueue! = nil
    
    //lights
    
    var m_light:GameLightArrary! = nil
    
    
    

    
    //Shadow Pass
    
    //Pass 2: G-Buffer
    var m_geometryPipelineState:MTLRenderPipelineState! = nil
    var m_geometryDepthStencilState:MTLDepthStencilState! = nil
    //Pass 2: Composition
    var m_compositionPipelineState:MTLRenderPipelineState! = nil
    var m_compositionDepthStencilState:MTLDepthStencilState! = nil
    
    var m_secondPassDesc:MTLRenderPassDescriptor! = nil
    
    var m_colorattachmentDesc = MTLRenderPassColorAttachmentDescriptor()
    
    var m_screenQuard:GameActorAsset! = nil
    
    
    init(scene:GameScene) {
        super.init()
        m_scene = scene
        m_secondPassDesc = scene.m_utility.m_descriptor.m_renderPassDesc
        m_library = m_scene.m_device.newDefaultLibrary()
        m_commandQueue = m_scene.m_device.newCommandQueue()
        let light1 = GameLight(pos: [0,20,0], color: [1,1,1], shine: 10)
        let light2 = GameLight(pos: [5,5,5], color: [1,1,1], shine: 50)

        let light3 = GameLight(pos: [5,20,8], color: [1,0,0], shine: 70)

        let light4 = GameLight(pos: [0,20,9], color: [1,1,1], shine: 10)

        let light5 = GameLight(pos: [10,20,0], color: [0.1,0.5,0.6], shine: 4)
        let light6 = GameLight(pos: [2,20,6], color: [0.1,0.5,0.2], shine: 15)
        
        
        m_light = GameLightArrary(lights: [light1,light2,light3,light4,light5,light6], scene: m_scene)


        m_size = CGSize(width: 0, height: 0)
        setupGeometryState()
        setupCompostionState()
        m_screenQuard = GameActorAsset(vertices: screenQuard_vertices, indices: screenQuard_indices, primitiveType: MTLPrimitiveType.Triangle, device: m_scene.m_device)
        
        
    }
    
    
    
    
    
    //geometry stage 设置pipeline state
    
    
    func setupGeometryState(){
        let renderPipelineDesc = m_scene.m_utility.m_descriptor.m_renderPipelineDesc
        renderPipelineDesc.vertexFunction = m_library.newFunctionWithName("gbufferVertex")
        renderPipelineDesc.fragmentFunction = m_library.newFunctionWithName("gbufferFragment")
        
        
        renderPipelineDesc.colorAttachments[0].pixelFormat = m_scene.m_mtkView.colorPixelFormat
        renderPipelineDesc.colorAttachments[1].pixelFormat = MTLPixelFormat.RGBA16Float
        //m_scene.m_mtkView.colorPixelFormat
        //renderPipelineDesc.colorAttachments[2].pixelFormat = MTLPixelFormat.RGBA16Float
        //m_scene.m_mtkView.colorPixelFormat
        //renderPipelineDesc.colorAttachments[3].pixelFormat = m_scene.m_mtkView.colorPixelFormat

        
        
        renderPipelineDesc.depthAttachmentPixelFormat = m_scene.m_mtkView.depthStencilPixelFormat
        renderPipelineDesc.stencilAttachmentPixelFormat = m_scene.m_mtkView.depthStencilPixelFormat
        
        do{
            m_geometryPipelineState = try m_scene.m_device.newRenderPipelineStateWithDescriptor(renderPipelineDesc)
        }catch let error as NSError{
            print("(GameDefferedRender.swift setupGeometryState() function) :\(error.localizedDescription),\(error.localizedRecoverySuggestion)")
        }
        
        
        let depthStencilDesc = m_scene.m_utility.m_descriptor.m_depthDesc
        depthStencilDesc.depthWriteEnabled = true
        depthStencilDesc.depthCompareFunction = MTLCompareFunction.LessEqual
        m_geometryDepthStencilState = m_scene.m_device.newDepthStencilStateWithDescriptor(depthStencilDesc)
    }
    
    
     //设置composition stage pipelinestate
    
    
    func setupCompostionState(){
        let renderPipelineDesc = m_scene.m_utility.m_descriptor.m_renderPipelineDesc
        renderPipelineDesc.vertexFunction = m_library.newFunctionWithName("CompositonVertex")
        renderPipelineDesc.fragmentFunction = m_library.newFunctionWithName("CompositionFragment")
       
    

        
        do{
            m_compositionPipelineState = try m_scene.m_device.newRenderPipelineStateWithDescriptor(renderPipelineDesc)
        }catch let error as NSError{
            print("(GameDefferedRender.swift setupComposition() function) :\(error.localizedDescription)")

        }
        
        
        let depthStencilDesc = m_scene.m_utility.m_descriptor.m_depthDesc
        depthStencilDesc.depthWriteEnabled = false
        m_compositionDepthStencilState = m_scene.m_device.newDepthStencilStateWithDescriptor(depthStencilDesc)
    }
    
    
    func setupSecondPassRenderPassDesc(texture:MTLTexture)->MTLRenderPassDescriptor{
        m_colorattachmentDesc.texture = texture
        m_colorattachmentDesc.loadAction = MTLLoadAction.Clear
        m_colorattachmentDesc.storeAction = MTLStoreAction.Store
        m_colorattachmentDesc.clearColor = MTLClearColorMake(0, 0, 0, 1)
        m_secondPassDesc.colorAttachments[0] = m_colorattachmentDesc
        
        
        
        //如果screen没有变，不需要更新colorattachments
        if m_sizeChanged == true{
            
            
            let textureDesc = m_scene.m_utility.m_descriptor.m_textureDesc
            textureDesc.width = Int(m_size.width)
            textureDesc.height = Int(m_size.height)
            textureDesc.textureType = MTLTextureType.Type2D
            
            
            //设置
            
            /*for var i = 1 ; i < 3 ; ++i{
                m_colorattachmentDesc.texture = m_scene.m_device.newTextureWithDescriptor(textureDesc)
                m_colorattachmentDesc.loadAction = MTLLoadAction.Clear
                m_colorattachmentDesc.storeAction = MTLStoreAction.DontCare
                m_colorattachmentDesc.clearColor = MTLClearColorMake(0, 0, 0, 1)
                m_secondPassDesc.colorAttachments[i] = m_colorattachmentDesc
            }*/
            
            textureDesc.pixelFormat = MTLPixelFormat.RGBA16Float

            m_colorattachmentDesc.texture = m_scene.m_device.newTextureWithDescriptor(textureDesc)
            m_colorattachmentDesc.loadAction = MTLLoadAction.Clear
            m_colorattachmentDesc.storeAction = MTLStoreAction.DontCare
            m_colorattachmentDesc.clearColor = MTLClearColorMake(0, 0, 0, 1)
            m_secondPassDesc.colorAttachments[1] = m_colorattachmentDesc
            
            /*textureDesc.pixelFormat = MTLPixelFormat.RGBA16Float
            
            m_colorattachmentDesc.texture = m_scene.m_device.newTextureWithDescriptor(textureDesc)
            m_colorattachmentDesc.loadAction = MTLLoadAction.Clear
            m_colorattachmentDesc.storeAction = MTLStoreAction.DontCare
            m_colorattachmentDesc.clearColor = MTLClearColorMake(0, 0, 0, 1)
            m_secondPassDesc.colorAttachments[2] = m_colorattachmentDesc*/
            
            
            
            
            textureDesc.pixelFormat = MTLPixelFormat.Depth32Float_Stencil8
            
            let deptAttachmentDesc = m_scene.m_utility.m_descriptor.m_deptAttachmentDesc
            deptAttachmentDesc.texture = m_scene.m_device.newTextureWithDescriptor(textureDesc)
            deptAttachmentDesc.loadAction = MTLLoadAction.Clear
            deptAttachmentDesc.storeAction = MTLStoreAction.Store
            deptAttachmentDesc.clearDepth = 1
            
            
            let stencilAttachmentDesc = m_scene.m_utility.m_descriptor.m_stencilAttachmentDesc
            stencilAttachmentDesc.texture = deptAttachmentDesc.texture!
            stencilAttachmentDesc.loadAction = MTLLoadAction.Clear
            stencilAttachmentDesc.storeAction = MTLStoreAction.Store
            stencilAttachmentDesc.clearStencil = 0
            
            m_secondPassDesc.depthAttachment = deptAttachmentDesc
            m_secondPassDesc.stencilAttachment = stencilAttachmentDesc
            
            m_sizeChanged = false
        }
        return m_secondPassDesc
    }
    
    func renderToScreen(encoder:MTLRenderCommandEncoder){
        encoder.setVertexBuffer(m_screenQuard.m_vertexBuffer, offset: 0, atIndex: 0)
        encoder.setRenderPipelineState(m_compositionPipelineState)
        encoder.setDepthStencilState(m_compositionDepthStencilState)
        encoder.drawIndexedPrimitives(m_screenQuard.m_primitiveType, indexCount: m_screenQuard.m_indices.count, indexType: MTLIndexType.UInt16, indexBuffer: m_screenQuard.m_indexBuffer, indexBufferOffset: 0)
    }
    
    
    
    
    
    
    
    
    func drawInMTKView(view: MTKView) {
        m_scene.m_actor[0].rotate(0.02, axis: [0,0,1])
        m_scene.m_actor[1].rotate(-0.02, axis: [0,1,0])
        m_scene.m_actor[2].rotate(0.02, axis: [0,0,1])
        m_scene.m_actor[3].rotate(-0.02, axis: [0,0,1])
        
        let commandBuffer = m_commandQueue.commandBuffer()
        let encoder = commandBuffer.renderCommandEncoderWithDescriptor(setupSecondPassRenderPassDesc(view.currentDrawable!.texture))
        //1.Gbuffer Render
        encoder.label = "G-buffer"
        for actor in m_scene.m_actor{
            actor.renderWithPipelineStates(encoder, pipelineState: m_geometryPipelineState, depthState: m_geometryDepthStencilState)
            
            
        }
        
        
        //2/composition Render
        encoder.label = "Composition"
        encoder.setFragmentBuffer(m_light.m_lightsBuffer.buffer(), offset: 0, atIndex: 0)
        encoder.setFragmentBuffer(m_scene.m_utility.m_camera.viewBuffer(), offset: 0, atIndex: 1)
        //encoder.setVertexBuffer(m_scene.m_utility.m_camera.viewBuffer(), offset: 0, atIndex: 3)
        //encoder.setFragmentBuffer(m_scene.m_utility.m_camera.viewBuffer(), offset: 0, atIndex: 3)
        renderToScreen(encoder)
        
        
        
        
        
        
        encoder.endEncoding()
        commandBuffer.presentDrawable(view.currentDrawable!)
        commandBuffer.commit()

    }
    
    
    func mtkView(view: MTKView, drawableSizeWillChange size: CGSize) {
        m_sizeChanged = true
        m_size = size
        m_scene.m_utility.m_camera.changeSize()
    }
}