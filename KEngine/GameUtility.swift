//
//  SceneUtility.swift
//  KEngine
//
//  Created by 哈哈 on 15/8/27.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import Metal
import MetalKit
import MetalPerformanceShaders



class GameUtility:NSObject {
    var m_scene:GameScene! = nil
    var m_descriptor:Descriptor! = nil
    var m_camera:GameCamera! = nil
    var m_gaussianBlur:MPSImageGaussianBlur! = nil
    var m_library:MTLLibrary! = nil
    var m_textureLoader:MTKTextureLoader! = nil
    
    init(scene:GameScene) {
        super.init()
        m_scene = scene
        m_descriptor = Descriptor()
        m_camera = GameCamera(pos: [30,30,30], center: [0,0,0], up: [0,1,0], scene: scene)
        m_library = m_scene.m_device.newDefaultLibrary()
        m_textureLoader = MTKTextureLoader(device: m_scene.m_device)
        //m_gaussianBlur = MPSImageGaussianBlur(device: m_scene.m_device, sigma:0.5)
    }
}