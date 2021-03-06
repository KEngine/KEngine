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
    var m_shadowMapBlur:MTLTexture! = nil
    var m_depthAttach:MTLTexture! = nil
    var m_shadowPass = MTLRenderPassDescriptor()
    var m_shadowPipelieState:MTLRenderPipelineState! = nil
    var m_shadowDepthStencilState:MTLDepthStencilState! = nil
    
    
    //Pass 2: G-Buffer
    var m_geometryPipelineState:MTLRenderPipelineState! = nil
    var m_geometryDepthStencilState:MTLDepthStencilState! = nil
    
    //Pass 2 : Light
    
    //light mask (Render A Stencil Buffer)
    var m_lightMaskPipelineState:MTLRenderPipelineState! = nil
    var m_lightMaskDepthStencilState:MTLDepthStencilState! = nil
    //light color (Render Light Color Indeed)
    var m_lightColorPipelineState:MTLRenderPipelineState! = nil
    var m_lightColorDepthStencilState:MTLDepthStencilState! = nil
    var m_lightColorDepthStencilStateNoDepth:MTLDepthStencilState! = nil
    
    
    //Pass 2: Composition
    var m_compositionPipelineState:MTLRenderPipelineState! = nil
    var m_compositionDepthStencilState:MTLDepthStencilState! = nil
    
    //Pass2 : UI
    
    var m_renderUIPipelineState:MTLRenderPipelineState! = nil
    var m_quardTextCoord:MTLBuffer! = nil
    
    var m_secondPassDesc:MTLRenderPassDescriptor! = nil
    
    var m_colorattachmentDesc = MTLRenderPassColorAttachmentDescriptor()
    
    var m_screenQuard:GameActorAsset! = nil
    
    var m_shadowMapFilter:GameFilter! = nil
    var m_gaussianBlur : GameGaussianBlur! = nil
    
    init(scene:GameScene) {
        super.init()
        m_scene = scene
        m_secondPassDesc = scene.m_utility.m_descriptor.m_renderPassDesc
        m_library = m_scene.m_utility.m_library
        m_commandQueue = m_scene.m_device.newCommandQueue()
        
        //Shadow Pass
        shadowPassDesc()
        setupShadowState()

        
        
        //Second Pass
        setupGeometryState()
        setupLightState()
        setupCompostionState()
        m_screenQuard = GameActorAsset(vertices: screenQuard_vertices, indices: screenQuard_indices, primitiveType: MTLPrimitiveType.Triangle, device: m_scene.m_device)
        //m_shadowMapFilter = GameFilter(functionName: "GaussianBlur", soureceTexture: m_shadowMap, targetTexture: m_shadowMapBlur, scene: m_scene)
        m_gaussianBlur = GameGaussianBlur(scene: m_scene)
        m_quardTextCoord = m_scene.m_device.newBufferWithBytes(quard_textCoord, length: sizeofValue(quard_textCoord[0]) * quard_textCoord.count, options: MTLResourceOptions.CPUCacheModeDefaultCache)
    }
    
        
    
    func shadowPassDesc()->MTLRenderPassDescriptor{
        let textureDesc = m_scene.m_utility.m_descriptor.m_textureDesc
        textureDesc.textureType = MTLTextureType.Type2D
        textureDesc.width = Int(1024)
        textureDesc.height = Int(1024)
        textureDesc.mipmapLevelCount = 1
        textureDesc.pixelFormat = MTLPixelFormat.RG32Float
        m_shadowMap = m_scene.m_device.newTextureWithDescriptor(textureDesc)
        
        
    
        m_shadowMapBlur = m_scene.m_device.newTextureWithDescriptor(textureDesc)
        m_shadowPass.colorAttachments[0].texture = m_shadowMap
        m_shadowPass.colorAttachments[0].storeAction = .Store
        m_shadowPass.colorAttachments[0].loadAction = MTLLoadAction.Clear
        m_shadowPass.colorAttachments[0].clearColor = MTLClearColorMake(0,0,0,1)
        

        
        
        /*textureDesc.textureType = MTLTextureType.Type2D
        textureDesc.width = Int(1024)
        textureDesc.height = Int(1024)
        textureDesc.mipmapLevelCount = 1
        textureDesc.pixelFormat = MTLPixelFormat.Depth32Float
        m_depthAttach = m_scene.m_device.newTextureWithDescriptor(textureDesc)
        m_shadowPass.depthAttachment.texture = m_depthAttach
        m_shadowPass.depthAttachment.storeAction = MTLStoreAction.Store
        m_shadowPass.depthAttachment.loadAction = MTLLoadAction.Clear
        m_shadowPass.depthAttachment.clearDepth = 1.0*/
        
        
        return m_shadowPass
    }
    
    func setupShadowState(){
        let shadowPipelineStateDesc = m_scene.m_utility.m_descriptor.m_renderPipelineDesc
        shadowPipelineStateDesc.vertexFunction = m_library.newFunctionWithName("renderShadowMapVertex")
        shadowPipelineStateDesc.fragmentFunction = m_library.newFunctionWithName("renderShadowMapFragment")
        shadowPipelineStateDesc.colorAttachments[0].pixelFormat = m_shadowMap.pixelFormat
        //shadowPipelineStateDesc.depthAttachmentPixelFormat = MTLPixelFormat.Depth32Float
        
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
        encoder.setVertexBuffer(m_scene.m_utility.m_camera.shadowProjecitonBuffer(), offset: 0, atIndex: 1)
        encoder.setVertexBuffer(m_scene.m_utility.m_camera.sunViewBuffer(), offset: 0, atIndex: 3)
        //encoder.setDepthBias(0.05, slopeScale: 1.1, clamp: 1)
        //encoder.setCullMode(.Back)
        for actor in m_scene.m_actor{
            actor.renderToShadowMap(encoder, pipelineState: m_shadowPipelieState,depthState:m_shadowDepthStencilState)
        }
        
        //encoder.setCullMode(MTLCullMode.None)

        encoder.endEncoding()
    }
    
    
    
    
    
    //geometry stage 设置pipeline state
    
    
    func setupGeometryState(){
        let renderPipelineDesc = m_scene.m_utility.m_descriptor.m_renderPipelineDesc
        renderPipelineDesc.vertexFunction = m_library.newFunctionWithName("gbufferVertex")
        renderPipelineDesc.fragmentFunction = m_library.newFunctionWithName("gbufferFragment")
        
        
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
    
    
    
    //设置light state pipelinestate
    
    
    func setupLightState(){
        let renderpipelineDesc = m_scene.m_utility.m_descriptor.m_renderPipelineDesc
        let depthStencilDesc = m_scene.m_utility.m_descriptor.m_depthDesc
        let stencilState = m_scene.m_utility.m_descriptor.m_stencilDesc
        
        depthStencilDesc.depthWriteEnabled = false
        stencilState.stencilCompareFunction = MTLCompareFunction.Equal
        stencilState.stencilFailureOperation = MTLStencilOperation.Keep
        stencilState.depthFailureOperation = MTLStencilOperation.IncrementClamp
        stencilState.depthStencilPassOperation = MTLStencilOperation.Keep
        stencilState.writeMask = 0xFF
        stencilState.readMask = 0xFF
        depthStencilDesc.depthCompareFunction = MTLCompareFunction.LessEqual
        depthStencilDesc.frontFaceStencil = stencilState
        depthStencilDesc.backFaceStencil = stencilState
        m_lightMaskDepthStencilState = m_scene.m_device.newDepthStencilStateWithDescriptor(depthStencilDesc)
        
        
        
        depthStencilDesc.depthWriteEnabled = false
        stencilState.stencilCompareFunction = MTLCompareFunction.Less
        stencilState.stencilFailureOperation = MTLStencilOperation.Keep
        stencilState.depthFailureOperation = MTLStencilOperation.DecrementClamp
        stencilState.depthStencilPassOperation = MTLStencilOperation.DecrementClamp
        stencilState.writeMask = 0xFF
        stencilState.readMask = 0xFF
        depthStencilDesc.depthCompareFunction = MTLCompareFunction.LessEqual
        depthStencilDesc.frontFaceStencil = stencilState
        depthStencilDesc.backFaceStencil = stencilState
        m_lightColorDepthStencilState = m_scene.m_device.newDepthStencilStateWithDescriptor(depthStencilDesc)
        
        depthStencilDesc.depthCompareFunction = MTLCompareFunction.Always
        m_lightColorDepthStencilStateNoDepth = m_scene.m_device.newDepthStencilStateWithDescriptor(depthStencilDesc)
        
        renderpipelineDesc.label = "Light Mask Render"
        renderpipelineDesc.vertexFunction = m_library.newFunctionWithName("lightVertex")
        renderpipelineDesc.fragmentFunction = nil
        for var i = 0 ; i <= 3 ; ++i{
            renderpipelineDesc.colorAttachments[i].writeMask = MTLColorWriteMask.None
        }
        do{
            m_lightMaskPipelineState = try m_scene.m_device.newRenderPipelineStateWithDescriptor(renderpipelineDesc)
        }catch let error as NSError{
            fatalError(error.localizedDescription)
        }
        
        renderpipelineDesc.label = "Light Color Render"
        renderpipelineDesc.vertexFunction = m_library.newFunctionWithName("lightVertex")
        renderpipelineDesc.fragmentFunction = m_library.newFunctionWithName("lightFragment")
        for var i = 0 ; i <= 3 ; ++i{
            renderpipelineDesc.colorAttachments[i].writeMask = MTLColorWriteMask.All
        }
        do{
            m_lightColorPipelineState = try m_scene.m_device.newRenderPipelineStateWithDescriptor(renderpipelineDesc)
        }catch let error as NSError{
            fatalError(error.localizedDescription)
        }
    }
    
    
    func renderLight(encoder:MTLRenderCommandEncoder){
        //1.Light Mask
        
       // m_secondPassDesc.colorAttachments[3].loadAction = MTLLoadAction.Load
       // m_secondPassDesc.colorAttachments[3].storeAction = MTLStoreAction.Store
        
        encoder.label = "Light"
        encoder.setStencilReferenceValue(128)
        encoder.setVertexBuffer(m_scene.m_utility.m_camera.m_projectionBuffer.buffer(), offset: 0, atIndex: 1)
        encoder.setVertexBuffer(m_scene.m_utility.m_camera.m_viewBuffer.buffer(), offset: 0, atIndex: 2)
        encoder.setFragmentBuffer(m_scene.m_utility.m_camera.viewBuffer(), offset: 0, atIndex: 1)

        //encoder.popDebugGroup()
        for light in m_scene.m_light{
            //encoder.pushDebugGroup("Stencil")
            encoder.setCullMode(MTLCullMode.Front)

            light.renderWithPipelineStates(encoder, pipelineState: m_lightMaskPipelineState, depthState: m_lightMaskDepthStencilState)
            //encoder.popDebugGroup()

            //encoder.pushDebugGroup("Volume")

            encoder.setCullMode(.Back)
             light.renderWithPipelineStates(encoder, pipelineState: m_lightColorPipelineState, depthState: m_lightColorDepthStencilState)
            //encoder.popDebugGroup()

        }
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
        
        renderPipelineDesc.vertexFunction = m_library.newFunctionWithName("RenderUIVertex")
        renderPipelineDesc.fragmentFunction = m_library.newFunctionWithName("RenderUIFragment")
        
        renderPipelineDesc.colorAttachments[0].blendingEnabled = true;
        renderPipelineDesc.colorAttachments[0].rgbBlendOperation = MTLBlendOperation.Add;
        renderPipelineDesc.colorAttachments[0].alphaBlendOperation = MTLBlendOperation.Add;
        renderPipelineDesc.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactor.One;
        renderPipelineDesc.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactor.One;
        renderPipelineDesc.colorAttachments[0].destinationRGBBlendFactor =
            MTLBlendFactor.OneMinusSourceAlpha;
        renderPipelineDesc.colorAttachments[0].destinationAlphaBlendFactor =
            MTLBlendFactor.OneMinusSourceAlpha;
        
        do{
            m_renderUIPipelineState = try m_scene.m_device.newRenderPipelineStateWithDescriptor(renderPipelineDesc)
        }catch let error as NSError{
            print("(GameDefferedRender.swift setupComposition() function) :\(error.localizedDescription)")
            
        }

        
        
        
        
        
        
        
        
        let depthStencilDesc = m_scene.m_utility.m_descriptor.m_depthDesc
        let stencilState = m_scene.m_utility.m_descriptor.m_stencilDesc
        
        depthStencilDesc.depthWriteEnabled = false
        stencilState.stencilCompareFunction = MTLCompareFunction.Equal
        stencilState.stencilFailureOperation = .Keep
        stencilState.depthFailureOperation = .Keep
        stencilState.depthStencilPassOperation = .Keep
        stencilState.readMask = 0xFF
        stencilState.writeMask = 0
        depthStencilDesc.frontFaceStencil = stencilState
        depthStencilDesc.backFaceStencil = stencilState
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
            
            textureDesc.pixelFormat = MTLPixelFormat.RGBA16Float
            
            m_colorattachmentDesc.texture = m_scene.m_device.newTextureWithDescriptor(textureDesc)
            m_colorattachmentDesc.loadAction = MTLLoadAction.Clear
            m_colorattachmentDesc.storeAction = MTLStoreAction.DontCare
            m_colorattachmentDesc.clearColor = MTLClearColorMake(1, 1, 1, 1)
            m_secondPassDesc.colorAttachments[3] = m_colorattachmentDesc
            
            
            
            
            textureDesc.pixelFormat = MTLPixelFormat.Depth32Float_Stencil8
            
            let deptAttachmentDesc = m_scene.m_utility.m_descriptor.m_deptAttachmentDesc
            deptAttachmentDesc.texture = m_scene.m_device.newTextureWithDescriptor(textureDesc)
            deptAttachmentDesc.loadAction = MTLLoadAction.Clear
            deptAttachmentDesc.storeAction = MTLStoreAction.DontCare
            deptAttachmentDesc.clearDepth = 1
            
            
            let stencilAttachmentDesc = m_scene.m_utility.m_descriptor.m_stencilAttachmentDesc
            stencilAttachmentDesc.texture = deptAttachmentDesc.texture
            stencilAttachmentDesc.loadAction = MTLLoadAction.Clear
            stencilAttachmentDesc.storeAction = MTLStoreAction.DontCare
            stencilAttachmentDesc.clearStencil = 0
            //let depthStencilDesc = m_scene.m_utility.m_descriptor.m_deptAttachmentDesc
            
        
            
            m_secondPassDesc.depthAttachment = deptAttachmentDesc
            m_secondPassDesc.stencilAttachment = stencilAttachmentDesc
            
            m_sizeChanged = false
        }
        return m_secondPassDesc
    }
    
    func renderToScreen(encoder:MTLRenderCommandEncoder){
        //setupCompostionActions()
        encoder.label = "RenderToScreen"
        encoder.setCullMode(.None)
        encoder.setFragmentBuffer(m_scene.m_utility.m_camera.m_light.m_lightsBuffer.buffer(), offset: 0, atIndex: 0)
        encoder.setFragmentBuffer(m_scene.m_utility.m_camera.viewBuffer(), offset: 0, atIndex: 1)
        encoder.setFragmentBuffer(m_scene.m_utility.m_camera.shadowProjecitonBuffer(), offset: 0, atIndex: 2)
        encoder.setFragmentBuffer(m_scene.m_utility.m_camera.sunViewBuffer(), offset: 0, atIndex: 3)
        encoder.setFragmentTexture(m_shadowMapBlur, atIndex: 0)
        encoder.setVertexBuffer(m_screenQuard.vertexBuffer(), offset: 0, atIndex: 0)
        encoder.setRenderPipelineState(m_compositionPipelineState)
        encoder.setDepthStencilState(m_compositionDepthStencilState)
        encoder.drawIndexedPrimitives(m_screenQuard.m_primitiveType, indexCount: m_screenQuard.m_indices.count,indexType: MTLIndexType.UInt16, indexBuffer: m_screenQuard.indexBuffer(), indexBufferOffset: 0)
    }
    
    
    func renderToGbuffer(encoder:MTLRenderCommandEncoder){
        //m_secondPassDesc.colorAttachments[0].loadAction = MTLLoadAction.DontCare
        //m_secondPassDesc.colorAttachments[0].storeAction = MTLStoreAction.DontCare
        //encoder.setCullMode(.Back)
        encoder.label = "G-buffer"
        //encoder.setCullMode(MTLCullMode.Back)
        encoder.setStencilReferenceValue(128)
        encoder.setVertexBuffer(m_scene.m_utility.m_camera.projectionBuffer(), offset: 0, atIndex: 1)
        encoder.setVertexBuffer(m_scene.m_utility.m_camera.viewBuffer(), offset: 0, atIndex: 3)

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
        
        m_secondPassDesc.colorAttachments[2].storeAction = MTLStoreAction.DontCare
        m_secondPassDesc.colorAttachments[2].loadAction = MTLLoadAction.DontCare

        m_secondPassDesc.colorAttachments[3].storeAction = MTLStoreAction.DontCare
        m_secondPassDesc.colorAttachments[3].loadAction = MTLLoadAction.DontCare

        
        m_secondPassDesc.depthAttachment.loadAction = MTLLoadAction.DontCare
        m_secondPassDesc.depthAttachment.storeAction  = MTLStoreAction.DontCare
        m_secondPassDesc.stencilAttachment.loadAction = MTLLoadAction.DontCare
        m_secondPassDesc.stencilAttachment.storeAction = MTLStoreAction.DontCare
    }
    
    
    func renderUI(encoder:MTLRenderCommandEncoder){
        encoder.setVertexBuffer(m_quardTextCoord, offset: 0, atIndex: 1)
        for ui in m_scene.m_ui{
            ui.renderUI(encoder)
        }
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
        
        /*let computeEncoder = commandBuffer.computeCommandEncoder()
        m_shadowMapFilter.applyFilter(computeEncoder)*/
        
        m_gaussianBlur.applyGaussian(commandBuffer, source: m_shadowMap, destnation: m_shadowMapBlur)
        let encoder = commandBuffer.renderCommandEncoderWithDescriptor(setupSecondPassRenderPassDesc(view.currentDrawable!.texture))

        //1.Gbuffer Render
        renderToGbuffer(encoder)
        
        
        
        //2.Light Render
        renderLight(encoder)
        
        
        
        //3.composition Render
        
        renderToScreen(encoder)
        
        //4.render UI
        
        //renderUI(encoder)

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
        //print(m_size)
        
        
        //UI比例调整
        for ui in m_scene.m_ui{
            ui.changeSize(Float(size.height / size.width))
        }
        m_scene.m_utility.m_camera.changeSize()
    }
}