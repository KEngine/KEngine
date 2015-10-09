//
//  GameGaussianFilter.swift
//  KEngine
//
//  Created by 哈哈 on 15/9/22.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import MetalPerformanceShaders




class GameGaussianBlur: NSObject {
    var m_gaussianFilter:MPSImageGaussianBlur! = nil
    var m_scene:GameScene! = nil
    init(scene:GameScene) {
        m_scene = scene
        m_gaussianFilter = MPSImageGaussianBlur(device: m_scene.m_device, sigma: 3)
    }
    
    func applyGaussian(commandBuffer:MTLCommandBuffer,source:MTLTexture,destnation:MTLTexture){
        m_gaussianFilter.encodeToCommandBuffer(commandBuffer, sourceTexture: source, destinationTexture: destnation)
    }
}
