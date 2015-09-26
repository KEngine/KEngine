//
//  GameGrid.swift
//  KEngine
//
//  Created by 哈哈 on 15/9/23.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import Metal
import simd




class GameGrid: NSObject {
    var m_vertex:[Float]! = nil
    var m_index:[UInt16]! = nil
    init(m0:float2,m1:float2,m2:float2,m3:float2,depth:Int) {
        super.init()
        m_vertex = [Float]()
        m_index = [UInt16]()
        initGrid(m0, m1: m1, m2: m2, m3: m3, depth: depth)
        
    }
    func vertex()->[Float]{
        return m_vertex
    }
    
    func index()->[UInt16]{
        return m_index
    }
    
    
    func initGrid(m0:float2,m1:float2,m2:float2,m3:float2,depth:Int){
        if depth > 1{
            let ma = float2(m0.x,(m0.y + m1.y) / 2)
            let mb = float2((m1.x + m2.x) / 2,m1.y)
            let mc = float2(m2.x,(m2.y + m3.y) / 2)
            let md = float2((m0.x + m3.x) / 2,m0.y)
            let me = float2(mb.x,ma.y)
            initGrid(m0, m1: ma, m2: me, m3: md, depth: depth - 1)
            initGrid(ma, m1: m1, m2: mb, m3: me, depth: depth - 1)
            initGrid(me, m1: mb, m2: m2, m3: mc, depth: depth - 1)
            initGrid(md, m1: me, m2: mc, m3: m3, depth: depth - 1)
        }
        if depth == 1{
            let vertexData:[Float] = [
                m0.x,0,m0.y,0,1,0,0,0,//0,0,Float(depth % 4),
                m1.x,0,m1.y,0,1,0,1,0,
                m2.x,0,m2.y,0,1,0,1,1,
                m3.x,0,m3.y,0,1,0,0,1,
            ]
            for ele in vertexData{
                m_vertex.append(ele)
            }
            let indexOffSet = m_index.count / 6 * 4
            let indexData = [indexOffSet,1 + indexOffSet,2 + indexOffSet,indexOffSet,2 + indexOffSet,3 + indexOffSet]
            for ele in indexData{
                m_index.append(UInt16(ele))
            }
        }
        
    }

}