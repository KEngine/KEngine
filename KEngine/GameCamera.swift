//
//  GameCamera.swift
//  KEngine
//
//  Created by 哈哈 on 15/8/29.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import Metal
import MetalKit




class GameCamera:NSObject,CameraDelegate {
    var m_viewMatrix = float4x4(1)
    var m_projectionMatrix = float4x4(1)
    var m_sunViewMatrix = float4x4(1)
    var m_viewBuffer:GameUniformBuffer! = nil
    var m_projectionBuffer:GameUniformBuffer! = nil
    var m_sunViewBuffer:GameUniformBuffer! = nil

    var m_scene:GameScene! = nil
    var m_lastPanLocation = CGPoint()
    var m_lastScale:CGFloat = 0
    var m_pos:[Float]! = nil
    
    
    
    
    //light
    var m_sunPos:[Float] = [100,100,100]
    var m_light:GameLightArrary! = nil


    var m_shadowProjectionMatrix = float4x4(0)
    var m_shadowProjectionBuffer:GameUniformBuffer! = nil
    //temp
    var m_pvMatrix = float4x4()
    var m_pvBuffer:GameUniformBuffer! = nil
    
    init(pos:[Float],center:[Float],up:[Float],scene:GameScene) {
        super.init()
        m_scene = scene
        m_pos = pos
        m_viewMatrix.matrixFromLookAt(m_pos, center: center, up: up)
        m_projectionMatrix.MatrixMakeFrustum_oc(-1, right: 1, bottom: -Float(scene.view.frame.width / scene.view.frame.height), top: Float(scene.view.frame.width / scene.view.frame.height), near: 0, far: -1000)
        setupLight()
        m_sunPos = m_light.m_sunPos
        m_viewBuffer = GameUniformBuffer(data: m_viewMatrix.dumpToSwift(), scene: scene)
        m_projectionBuffer = GameUniformBuffer(data: m_projectionMatrix.dumpToSwift(), scene: scene)
        m_sunViewMatrix.matrixFromLookAt(m_sunPos, center: [0,0,0], up: [0,1,0])
        m_sunViewBuffer = GameUniformBuffer(data: m_sunViewMatrix.dumpToSwift(), scene: scene)
        m_shadowProjectionMatrix.MatrixMakeFrustum_oc(-1, right: 1, bottom: -Float(scene.view.frame.width / scene.view.frame.height), top: Float(scene.view.frame.width / scene.view.frame.height), near: 50, far: -1000)
        m_shadowProjectionBuffer = GameUniformBuffer(data: m_shadowProjectionMatrix.dumpToSwift(), scene: m_scene)
        
        
    }
    
    
    func setupLight(){
        let light1 = GameLight(pos: [100,200,50], color: [1,1,1], shine: 50)
        let light2 = GameLight(pos: [-3,3,3], color: [0,1,0], shine: 1)
        
        let light3 = GameLight(pos: [7,3,-3], color: [0,0,1], shine: 1)
        
        let light4 = GameLight(pos: [3,3,3], color: [1,0.2,0.1], shine: 1)
        
        let light5 = GameLight(pos: [-3,3,-3], color: [0.1,0.5,0.6], shine: 1)
        let light6 = GameLight(pos: [-8,8,-9], color: [1,0.5,0.2], shine: 1)
        
        let light7 = GameLight(pos: [-8,4,1], color: [0.1,0.5,0.4], shine: 18)
        
        let light8 = GameLight(pos: [-3,0,5], color: [0.1,0.5,0.6], shine: 24)
        
        let light9 = GameLight(pos: [1,7,5], color: [0.8,0.5,0.5], shine: 14)
        
        let light10 = GameLight(pos: [10,1.5,5], color: [0.1,0.5,0.2], shine: 19)
        
        let ligh11 = GameLight(pos: [-7,3.5,-2], color: [0.3,0.5,0.6], shine: 34)
        
        
        m_light = GameLightArrary(lights: [light1,light2,light3,light4,light5,light6,ligh11,light10,light7,light8,light9], scene: m_scene)
        
        
    }

    
    func changeSize(){
        //print("changeSize")
         m_projectionMatrix.MatrixMakeFrustum_oc(-1, right: 1, bottom: -Float(m_scene.view.frame.width / m_scene.view.frame.height), top: Float(m_scene.view.frame.width / m_scene.view.frame.height), near: 1, far: -1000)
        m_projectionBuffer.updateBuffer(m_projectionMatrix.dumpToSwift())
        //m_pvMatrix = m_projectionMatrix * m_viewMatrix
       //return m_pvBuffer.updateBuffer(m_pvMatrix.dumpToSwift())
    }
    
    func viewBuffer()->MTLBuffer{
       return  m_viewBuffer.buffer()
    }
    
    
    func projectionBuffer()->MTLBuffer{
        return m_projectionBuffer.buffer()
    }
    
    
    func pvBuffer()->MTLBuffer{
        return m_pvBuffer.buffer()
    }
    
    func sunViewBuffer()->MTLBuffer{
        return m_sunViewBuffer.buffer()
    }
    
    func shadowProjecitonBuffer()->MTLBuffer{
        return m_shadowProjectionBuffer.buffer()
    }
    
    func rotate(location:CGPoint){
        
        
        
        /*if m_lastPanLocation.y < location.y{
            m_viewMatrix.rotate(0.04, axis: [1,0,-1])
            //m_viewMatrix.translate(0, y: 0.5, z: 0)
            m_viewBuffer.updateBuffer(m_viewMatrix.dumpToSwift())
        }else{
            m_viewMatrix.rotate(-0.04, axis: [1,0,-1])
            //m_viewMatrix.translate(0, y: -0.5, z: 0)
            m_viewBuffer.updateBuffer(m_viewMatrix.dumpToSwift())
        }
        m_lastPanLocation = location*/
        
        /*if m_lastPanLocation.x < location.x{
            m_pos[0] -= 1
        }else{
            m_pos[0] += 1
        }*/
        
        /*if m_lastPanLocation.y < location.y{
            m_pos[1] -= 1
        }else{
            m_pos[1] += 1
        }
        m_viewMatrix.matrixFromLookAt(m_pos, center: [0,0,0], up: [0,1,0])*/
        //m_viewBuffer.updateBuffer(m_viewMatrix.dumpToSwift())
        if abs(m_lastPanLocation.x - location.x) > abs(m_lastPanLocation.y - location.y){
            if m_lastPanLocation.x < location.x{
                m_pos[0] -= 1
            }else{
                m_pos[0] += 1
            }
            m_viewMatrix.matrixFromLookAt(m_pos, center: [0,0,0], up: [0,1,0])

        }else{
            if m_lastPanLocation.y < location.y{
                m_pos[1] -= 1
            }else{
                m_pos[1] += 1
            }
            m_viewMatrix.matrixFromLookAt(m_pos, center: [0,0,0], up: [0,1,0])
        }
        m_viewBuffer.updateBuffer(m_viewMatrix.dumpToSwift())

        m_lastPanLocation = location

        
        
    }
    
    func scale(scale:CGFloat) {
        if m_lastScale > scale{
            m_viewMatrix.translate(-0.5, y: -0.5, z: -0.5)
            m_viewBuffer.updateBuffer(m_viewMatrix.dumpToSwift())
        }else{
            m_viewMatrix.translate(0.5, y: 0.5, z: 0.5)
            m_viewBuffer.updateBuffer(m_viewMatrix.dumpToSwift())
        }
        m_lastScale = scale
    }
    
    
    
    
    
    
    
    
    
}