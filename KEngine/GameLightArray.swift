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
    var m_sunPos:[Float]! = nil
    init(lights:[GameLight],scene:GameScene) {
        super.init()
        m_lights = lights
        m_sunPos = [m_lights[0].m_light[0],m_lights[0].m_light[1],m_lights[0].m_light[2]]
        var data:[Float] = [Float]()
        for light in m_lights{
            data += light.m_light
        }
        
        m_lightsBuffer = GameUniformBuffer(data: data, scene: scene)
    }
}