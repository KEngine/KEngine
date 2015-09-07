//
//  GameLightArray.swift
//  KEngine
//
//  Created by 哈哈 on 15/9/7.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import Metal
import MetalKit


class GameLightArrary: NSObject {
    var m_lights :[GameLight]! = nil
    var m_lightsBuffer:GameUniformBuffer! = nil
    init(lights:[GameLight],scene:GameScene) {
        super.init()
        m_lights = lights
        var data:[Float] = [Float]()
        for light in m_lights{
            data += light.m_light
        }
        
        m_lightsBuffer = GameUniformBuffer(data: data, scene: scene)
    }
}