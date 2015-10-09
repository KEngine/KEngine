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
    var m_texture:MTLTexture! = nil
    init(vertices:[Float],indices:[UInt16],pos:[Float],scene:GameScene) {
        super.init()
        m_scene = scene
        m_asset = GameActorAsset(vertices: vertices, indices: indices,primitiveType:MTLPrimitiveType.Triangle,device:m_scene.m_device)
        m_modelMatrix.translate(pos[0], y: pos[1], z: pos[2])
        m_modelBuffer = GameUniformBuffer(data: m_modelMatrix.dumpToSwift(), scene: scene)
        
        do{
            m_texture = try m_scene.m_utility.m_textureLoader.newTextureWithContentsOfURL(NSBundle.mainBundle().URLForResource("default", withExtension:"png")!, options: nil)
        }catch let error as NSError{
            fatalError("Game Actor Texture Error:\(error.localizedDescription)")
        }

        
        
        m_scene.m_actor.append(self)
    }
    
    func updateModel(){
        m_modelBuffer.updateBuffer(m_modelMatrix.dumpToSwift())
    }
    
    
    init(filePath:String,pos:[Float],scene:GameScene){
        super.init()
        let meshData = NSData(contentsOfURL: NSBundle.mainBundle().URLForResource(filePath, withExtension: "json")!)
        //var error = NSErrorPointer()
        var jsonDict:NSDictionary
        do{
             jsonDict = try NSJSONSerialization.JSONObjectWithData(meshData!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        }catch let error as NSError{
            fatalError(error.localizedDescription)
        }
        
        let vertices = jsonDict.objectForKey("vertex") as? [Float]
        var vertexIndices = jsonDict.objectForKey("index") as? [Float]
        var indices = [UInt16]()
        for var i = 0 ; i < vertexIndices!.count ; ++i{
            indices.append(UInt16(vertexIndices![i]))
        }
        
        
        m_scene = scene
        m_asset = GameActorAsset(vertices: vertices!, indices: indices,primitiveType:MTLPrimitiveType.Triangle,device:m_scene.m_device)
        m_modelMatrix.translate(pos[0], y: pos[1], z: pos[2])
        m_modelBuffer = GameUniformBuffer(data: m_modelMatrix.dumpToSwift(), scene: scene)
        
        do{
            m_texture = try m_scene.m_utility.m_textureLoader.newTextureWithContentsOfURL(NSBundle.mainBundle().URLForResource("default", withExtension:"png")!, options: nil)
        }catch let error as NSError{
            fatalError("Game Actor Texture Error:\(error.localizedDescription)")
        }

        m_scene.m_actor.append(self)

        
    }
    
    func scale(scale:Float){
        m_modelMatrix.scale(scale)
        updateModel()
    }
    
    
    func translate(x:Float,y:Float,z:Float){
        m_modelMatrix.translate(x, y: y, z: z)
        updateModel()
    }
    
    func rotate(radians:Float,axis:[Float]){
        m_modelMatrix.rotate(radians, axis: axis)
        updateModel()
    }
    
    
    func renderToShadowMap(encoder: MTLRenderCommandEncoder,pipelineState:MTLRenderPipelineState,depthState:MTLDepthStencilState) {
        encoder.label = "shadow"
        //encoder.setDepthBias(0.05, slopeScale: 1.1, clamp: 1)
        //encoder.setCullMode(.Front)
        encoder.setVertexBuffer(m_asset.vertexBuffer(), offset: 0, atIndex: 0)
        encoder.setVertexBuffer(m_modelBuffer.buffer(), offset: 0, atIndex: 2)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setDepthStencilState(depthState)
        encoder.drawIndexedPrimitives(m_asset.m_primitiveType, indexCount: m_asset.m_indices.count, indexType: MTLIndexType.UInt16, indexBuffer: m_asset.m_indexBuffer, indexBufferOffset: 0)
        //encoder.setCullMode(.None)
    }
    
    func addTexture(textureName:String){
        do{
            m_texture = try m_scene.m_utility.m_textureLoader.newTextureWithContentsOfURL(NSBundle.mainBundle().URLForResource(textureName, withExtension:"png")!, options: nil)
        }catch let error as NSError{
            fatalError("Game Actor Texture Error:\(error.localizedDescription)")
        }
        
    }
    
    
    
    
       
    
    
    
    
    func renderWithPipelineStates(encoder: MTLRenderCommandEncoder,pipelineState:MTLRenderPipelineState,depthState:MTLDepthStencilState) {
        encoder.setVertexBuffer(m_asset.vertexBuffer(), offset: 0, atIndex: 0)
        encoder.setVertexBuffer(m_modelBuffer.buffer(), offset: 0, atIndex: 2)
        encoder.setFragmentTexture(m_texture, atIndex: 0)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setDepthStencilState(depthState)
        encoder.drawIndexedPrimitives(m_asset.m_primitiveType, indexCount: m_asset.m_indices.count, indexType: MTLIndexType.UInt16, indexBuffer: m_asset.m_indexBuffer, indexBufferOffset: 0)
    }
    
    
    
    
    
}