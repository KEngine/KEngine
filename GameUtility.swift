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



class GameUtility:NSObject {
    var m_scene:GameScene! = nil
    var m_descriptor:Descriptor! = nil
    var m_camera:GameCamera! = nil
    
    
    init(scene:GameScene) {
        super.init()
        m_scene = scene
        m_descriptor = Descriptor()
        m_camera = GameCamera(pos: [5,5,5], center: [0,0,0], up: [0,1,0], scene: scene)
    }
}