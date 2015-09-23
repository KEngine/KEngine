//
//  GameTerrainActor.swift
//  KEngine
//
//  Created by 哈哈 on 15/9/23.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import Metal
import simd



class GameTerrainActor:GameActor {
    var m_grid:GameGrid! = nil
    
    init(scene:GameScene,m0:float2,m1:float2,m2:float2,m3:float2,depth:Int) {
        m_grid = GameGrid(m0: m0, m1: m1, m2: m2, m3: m3, depth: depth)
        super.init(vertices: m_grid.m_vertex, indices: m_grid.m_index, pos: [0,0,0], scene: scene)
    }
}