//
//  GameFilter.swift
//  KEngine
//
//  Created by 哈哈 on 15/9/22.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import Metal



class GameFilter: NSObject {
    var m_funcName:String! = nil
    var m_scene:GameScene! = nil
    var m_computeState:MTLComputePipelineState! = nil
    var m_sourceTexture:MTLTexture! = nil
    var m_targetTexture:MTLTexture! = nil
    init(functionName:String,soureceTexture:MTLTexture,targetTexture:MTLTexture,scene:GameScene) {
        super.init()
        m_funcName = functionName
        m_scene = scene
        m_sourceTexture = soureceTexture
        m_targetTexture = targetTexture
        let computeFunc = m_scene.m_utility.m_library.newFunctionWithName(m_funcName)!
        do{
             m_computeState =  try m_scene.m_device.newComputePipelineStateWithFunction(computeFunc)
        }catch let error as NSError{
            fatalError(error.localizedDescription)
        }
        
    }
    
    
    func applyFilter(computeEncoder:MTLComputeCommandEncoder){
        computeEncoder.setComputePipelineState(m_computeState)
        computeEncoder.setTexture(m_sourceTexture, atIndex: 0)
        computeEncoder.setTexture(m_targetTexture, atIndex: 1)
        let threadsPerGroup = MTLSizeMake(4, 4, 1)
        let numThreadGroups = MTLSizeMake(m_sourceTexture.width / threadsPerGroup.width, m_sourceTexture.height / threadsPerGroup.height, 1)
        computeEncoder.dispatchThreadgroups(numThreadGroups, threadsPerThreadgroup: threadsPerGroup)
        computeEncoder.endEncoding()
    }
    
    
    

}