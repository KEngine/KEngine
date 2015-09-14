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
    
    var m_currentIndex:Int = 0
    var m_inflightSemaphore = dispatch_semaphore_create(3)
    
    
    
    
    //Shadow Pass
    var m_shadowMap:MTLTexture! = nil
    var m_shadowPass = MTLRenderPassDescriptor()
    var m_shadowPipelieState:MTLRenderPipelineState! = nil
    var m_shadowDepthStencilState:MTLDepthStencilState! = nil
    
    
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
        
        //Shadow Pass
        shadowPassDesc()
        setupShadowState()

        
        
        //Second Pass
        setupGeometryState()
        setupCompostionState()
        m_screenQuard = GameActorAsset(vertices: screenQuard_vertices, indices: screenQuard_indices, primitiveType: MTLPrimitiveType.Triangle, device: m_scene.m_device)
    }
    
        
    
    func shadowPassDesc()->MTLRenderPassDescriptor{
        /*if m_sizeChanged == true{
           let textureDesc = m_scene.m_utility.m_descriptor.m_textureDesc
            textureDesc.textureType = MTLTextureType.Type2D
            textureDesc.width = Int(m_size.width)
            textureDesc.height = Int(m_size.height)
            textureDesc.mipmapLevelCount = 1
            textureDesc.pixelFormat = MTLPixelFormat.Depth32Float
            m_shadowMap = m_scene.m_device.newTextureWithDescriptor(textureDesc)
            m_shadowPass.colorAttachments[0] = nil
            m_shadowPass.depthAttachment.texture = m_shadowMap
            m_shadowPass.depthAttachment.storeAction = MTLStoreAction.Store
            m_shadowPass.depthAttachment.loadAction = MTLLoadAction.Clear
            m_shadowPass.depthAttachment.clearDepth = 0.0

        }*/
        
        let textureDesc = m_scene.m_utility.m_descriptor.m_textureDesc
        textureDesc.textureType = MTLTextureType.Type2D
        textureDesc.width = Int(1024)
        textureDesc.height = Int(1024)
        textureDesc.mipmapLevelCount = 1
        textureDesc.pixelFormat = MTLPixelFormat.Depth32Float
        m_shadowMap = m_scene.m_device.newTextureWithDescriptor(textureDesc)
        m_shadowPass.colorAttachments[0] = nil
        m_shadowPass.depthAttachment.texture = m_shadowMap
        m_shadowPass.depthAttachment.storeAction = MTLStoreAction.Store
        m_shadowPass.depthAttachment.loadAction = MTLLoadAction.Clear
        m_shadowPass.depthAttachment.clearDepth = 1.0
        
        
        return m_shadowPass
    }
    
    func setupShadowState(){
        let shadowPipelineStateDesc = m_scene.m_utility.m_descriptor.m_renderPipelineDesc
        shadowPipelineStateDesc.vertexFunction = m_library.newFunctionWithName("renderShadowMap")
        shadowPipelineStateDesc.fragmentFunction = nil
        shadowPipelineStateDesc.depthAttachmentPixelFormat = MTLPixelFormat.Depth32Float
        
        do{
            try m_shadowPipelieState = m_scene.m_device.newRenderPipelineStateWithDescriptor(shadowPipelineStateDesc)
        }catch let error as NSError{
            fatalError(error.localizedDescription)
        }
        
        
        let depthStencilDesc = m_scene.m_utility.m_descriptor.m_depthDesc
        depthStencilDesc.depthWriteEnabled = true
        depthStencilDesc.depthCompareFunction = MTLCompareFunction.LessEqual
        m_shadowDepthStencilState = m_scene.m_device.newDepthStencilStateWithDescriptor(depthStencilDesc)
    }
    
    
    func renderShadowMap(encoder:MTLRenderCommandEncoder){
        for actor in m_scene.m_actor{
            actor.renderToShadowMap(encoder, pipelineState: m_shadowPipelieState,depthState:m_shadowDepthStencilState)
        }
    }
    
    
    
    
    
    //geometry stage 设置pipeline state
    
    
    func setupGeometryState(){
        let renderPipelineDesc = m_scene.m_utility.m_descriptor.m_renderPipelineDesc
        renderPipelineDesc.vertexFunction = m_library.newFunctionWithName("gbufferVertex")
        renderPipelineDesc.fragmentFunction = m_library.newFunctionWithName("gbufferFragment")
        
        
        renderPipelineDesc.colorAttachments[0].pixelFormat = m_scene.m_mtkView.colorPixelFormat
        renderPipelineDesc.colorAttachments[1].pixelFormat = MTLPixelFormat.RGBA16Float
        renderPipelineDesc.colorAttachments[2].pixelFormat = MTLPixelFormat.RGBA16Float
        //m_scene.m_mtkView.colorPixelFormat
        //renderPipelineDesc.colorAttachments[3].pixelFormat = m_scene.m_mtkView.colorPixelFormat

        
        
        renderPipelineDesc.depthAttachmentPixelFormat = m_scene.m_mtkView.depthStencilPixelFormat
        //renderPipelineDesc.stencilAttachmentPixelFormat = m_scene.m_mtkView.depthStencilPixelFormat
        
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
        m_colorattachmentDesc.clearColor = MTLClearColorMake(1, 1, 1, 1)
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
            m_colorattachmentDesc.clearColor = MTLClearColorMake(1, 1, 1, 1)
            m_secondPassDesc.colorAttachments[1] = m_colorattachmentDesc
            
            textureDesc.pixelFormat = MTLPixelFormat.RGBA16Float
            
            m_colorattachmentDesc.texture = m_scene.m_device.newTextureWithDescriptor(textureDesc)
            m_colorattachmentDesc.loadAction = MTLLoadAction.Clear
            m_colorattachmentDesc.storeAction = MTLStoreAction.DontCare
            m_colorattachmentDesc.clearColor = MTLClearColorMake(1, 1, 1, 1)
            m_secondPassDesc.colorAttachments[2] = m_colorattachmentDesc
            
            
            
            
            textureDesc.pixelFormat = MTLPixelFormat.Depth32Float
            
            let deptAttachmentDesc = m_scene.m_utility.m_descriptor.m_deptAttachmentDesc
            deptAttachmentDesc.texture = m_scene.m_device.newTextureWithDescriptor(textureDesc)
            deptAttachmentDesc.loadAction = MTLLoadAction.Clear
            deptAttachmentDesc.storeAction = MTLStoreAction.Store
            deptAttachmentDesc.clearDepth = 1
            
            
            /*let stencilAttachmentDesc = m_scene.m_utility.m_descriptor.m_stencilAttachmentDesc
            stencilAttachmentDesc.texture = deptAttachmentDesc.texture!
            stencilAttachmentDesc.loadAction = MTLLoadAction.Clear
            stencilAttachmentDesc.storeAction = MTLStoreAction.Store
            stencilAttachmentDesc.clearStencil = 1*/
            
            m_secondPassDesc.depthAttachment = deptAttachmentDesc
            //m_secondPassDesc.stencilAttachment = stencilAttachmentDesc
            
            m_sizeChanged = false
        }
        return m_secondPassDesc
    }
    
    func renderToScreen(encoder:MTLRenderCommandEncoder){
        setupCompostionActions()
        encoder.label = "RenderToScreen"
        encoder.setFragmentBuffer(m_scene.m_utility.m_camera.m_light.m_lightsBuffer.buffer(), offset: 0, atIndex: 0)
        encoder.setFragmentBuffer(m_scene.m_utility.m_camera.viewBuffer(), offset: 0, atIndex: 1)
        encoder.setFragmentBuffer(m_scene.m_utility.m_camera.shadowProjecitonBuffer(), offset: 0, atIndex: 2)
        encoder.setFragmentBuffer(m_scene.m_utility.m_camera.sunViewBuffer(), offset: 0, atIndex: 3)
        encoder.setFragmentTexture(m_shadowMap, atIndex: 0)
        encoder.setVertexBuffer(m_screenQuard.m_vertexBuffer, offset: 0, atIndex: 0)
        encoder.setRenderPipelineState(m_compositionPipelineState)
        encoder.setDepthStencilState(m_compositionDepthStencilState)
        encoder.drawIndexedPrimitives(m_screenQuard.m_primitiveType, indexCount: m_screenQuard.m_indices.count, indexType: MTLIndexType.UInt16, indexBuffer: m_screenQuard.m_indexBuffer, indexBufferOffset: 0)
    }
    
    
    func renderToGbuffer(encoder:MTLRenderCommandEncoder){
        m_secondPassDesc.colorAttachments[0].loadAction = MTLLoadAction.DontCare
        m_secondPassDesc.colorAttachments[0].storeAction = MTLStoreAction.DontCare
        encoder.label = "G-buffer"
        for actor in m_scene.m_actor{
            actor.renderWithPipelineStates(encoder, pipelineState: m_geometryPipelineState, depthState: m_geometryDepthStencilState)
            
            
        }
    }
    
    
    
    func setupCompostionActions(){
        m_secondPassDesc.colorAttachments[0].loadAction = MTLLoadAction.Clear
        m_secondPassDesc.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
        m_secondPassDesc.colorAttachments[0].storeAction = MTLStoreAction.Store
        
        m_secondPassDesc.colorAttachments[1].storeAction = MTLStoreAction.DontCare
        m_secondPassDesc.colorAttachments[1].loadAction = MTLLoadAction.DontCare
        //m_secondPassDesc.colorAttachments[1].clearColor = MTLClearColorMake(1,1,1,1)
        
        m_secondPassDesc.colorAttachments[2].storeAction = MTLStoreAction.DontCare
        m_secondPassDesc.colorAttachments[2].loadAction = MTLLoadAction.DontCare
        //m_secondPassDesc.colorAttachments[2].clearColor = MTLClearColorMake(1,1,1,1)
        
        m_secondPassDesc.depthAttachment.loadAction = MTLLoadAction.DontCare
        m_secondPassDesc.depthAttachment.storeAction  = MTLStoreAction.DontCare
        m_secondPassDesc.stencilAttachment.loadAction = MTLLoadAction.DontCare
        m_secondPassDesc.stencilAttachment.storeAction = MTLStoreAction.DontCare
    }

    
    
    
    
    
    
    
    
    
    
    
    //Draw Code
    func drawInMTKView(view: MTKView) {
        dispatch_semaphore_wait(m_inflightSemaphore, DISPATCH_TIME_FOREVER)
        //m_scene.m_utility.m_camera.m_viewMatrix.rotate(0.01, axis: [0,1,0])
        //m_scene.m_utility.m_camera.m_viewBuffer.updateBuffer(m_scene.m_utility.m_camera.m_viewMatrix.dumpToSwift())
        let commandBuffer = m_commandQueue.commandBuffer()
        
        
        
        
        m_scene.m_actor[0].rotate(0.02, axis: [0,0,1])
        m_scene.m_actor[1].rotate(-0.02, axis: [0,1,0])
        m_scene.m_actor[2].rotate(0.02, axis: [0,0,1])
        m_scene.m_actor[3].rotate(-0.02, axis: [0,0,1])
        
        //shadow
        let shadowEncoder = commandBuffer.renderCommandEncoderWithDescriptor(m_shadowPass)
        renderShadowMap(shadowEncoder)
        shadowEncoder.endEncoding()
        
        
        
        let encoder = commandBuffer.renderCommandEncoderWithDescriptor(setupSecondPassRenderPassDesc(view.currentDrawable!.texture))

        //1.Gbuffer Render
        renderToGbuffer(encoder)
        
        
        //2/composition Render
        
        renderToScreen(encoder)

        encoder.endEncoding()
        commandBuffer.addCompletedHandler{ [weak self] commandBuffer in
            if let strongSelf = self {
                dispatch_semaphore_signal(strongSelf.m_inflightSemaphore)
            }
            return
        }
        commandBuffer.presentDrawable(view.currentDrawable!)

        commandBuffer.commit()
        m_currentIndex = (m_currentIndex + 1) % 3


    }
    
    
    
    
    func mtkView(view: MTKView, drawableSizeWillChange size: CGSize) {
        m_sizeChanged = true
        m_size = size
        m_scene.m_utility.m_camera.changeSize()
    }
}