//
//  GameLight.swift
//  KEngine
//
//  Created by 哈哈 on 15/9/7.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import Metal
import MetalKit



class GameLight: NSObject{
    var m_light:[Float]! = nil
    init(pos:[Float],color:[Float],shine:Float) {
        super.init()
        m_light = [pos[0],pos[1],pos[2],color[0],color[1],color[2],shine]
        
    }
}