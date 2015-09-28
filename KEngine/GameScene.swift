//
//  GameScene.swift
//  KEngine
//
//  Created by 哈哈 on 15/8/27.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Metal
import MetalKit
import UIKit


protocol CameraDelegate{
    func rotate(location:CGPoint);

    func scale(scale:CGFloat)
}



class GameScene: UIViewController{
    var m_device:MTLDevice = MTLCreateSystemDefaultDevice()!
    var m_mtkView:MTKView! = nil
    var m_utility:GameUtility! = nil
    var m_renderDelegate:MTKViewDelegate! = nil
    var m_render:GameDefferedRender! = nil
    var m_actor:[GameActor]! = nil
    var m_light:[GameAreaLight]! = nil
    var m_cameraDelegate:CameraDelegate! = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        m_mtkView = self.view as! MTKView
        m_mtkView.device = m_device
        print(fmod(0.6, 0.25))
        /*let size = UIScreen.mainScreen().bounds
        let scale = UIScreen.mainScreen().scale
        
        
        //iphone 6 plus downsample its resolution
        //let iphone6P = CGFloat(1.15)
        //m_mtkView.drawableSize = CGSize(width: CGFloat(size.width * scale / iphone6P), height: CGFloat(size.height * scale / iphone6P))*/
        setupViewPixelFormat()
        
        //print(fract(double2(0.9 / 0.25)))
        
        // render utility actor init
        m_utility = GameUtility(scene: self)
        m_render = GameDefferedRender(scene: self)

        loadActor()
        m_mtkView.delegate = m_render
        m_cameraDelegate = m_utility.m_camera
        m_mtkView.preferredFramesPerSecond = 60
        addAppNotification()
        setupGesture()
        
    }
    
    func setupGesture(){
        m_mtkView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "Pan:"))
        m_mtkView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "Pinch:"))
    }
    
    func Pan(gesture:UIPanGestureRecognizer) {
            m_cameraDelegate.rotate(gesture.locationInView(m_mtkView))

    }
    
    func Pinch(gesture:UIPinchGestureRecognizer){
        m_cameraDelegate.scale(gesture.scale)
    }
    
    
    
    func addAppNotification(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "AppDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "AppWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    
    func AppDidEnterBackground(){
        m_mtkView.paused = true
    }
    
    func AppWillEnterForeground(){
        m_mtkView.paused = false
        m_mtkView.preferredFramesPerSecond = 60
    }
    
    
    func setupViewPixelFormat(){
        m_mtkView.colorPixelFormat = MTLPixelFormat.BGRA8Unorm
        m_mtkView.depthStencilPixelFormat = MTLPixelFormat.Depth32Float
    }
    
    
    func loadActor(){
        m_actor = [GameActor]()

        _ = GameActor(vertices: ball_vertices, indices: ball_indices,pos:[0,0,0], scene: self)
        //actor1.translate(0, y: 0, z: 0)
        
        _ = GameActor(vertices: sephere_vertices, indices: sephere_indices,pos:[0,0,3], scene: self)
        //actor2.translate(0, y: 0, z: 3)
        
        _ = GameActor(vertices: sephere_vertices, indices: sephere_indices,pos:[3,1,-4], scene: self)
        //actor3.translate(3, y: 1, z: -4)
        
        _ = GameActor(vertices: sephere_vertices, indices: sephere_indices,pos:[-5,0,-5], scene: self)
        //actor4.translate(-5, y: 0, z: -5)
        
        
        //_ = GameActor(vertices: plat_vertices, indices: plat_indices,pos:[0,8,0], scene: self)
        //actor5.translate(0, y: -5, z: 0)
        let terrain = GameTerrainActor(scene: self, m0: [250,-250], m1: [250,250], m2: [-250,150], m3: [-250,-250], depth: 6)
        terrain.translate(0, y: -10, z: 0)
        m_light = [GameAreaLight]()
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-7,1,0], color: [1,0,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [5,1,0], color: [0,1,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-1,0,1], color: [1,0,1], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [6,2,-7], color: [1,1,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [0,1,8], color: [0,1,1], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-8,2,2], color: [1,0,1], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [4.6,3,-2], color: [1,0,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-2,2,-2], color: [0,0,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [2,5,8], color: [1,0.5,0], scene: self)
        
        /*_ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-1,2,5], color: [1,0,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [2.5,1.0,3], color: [0,1,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-8,8,1], color: [1,0,1], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-1,2,-7], color: [1,1,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [1,-1,8], color: [0,1,1], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-3,2,1], color: [1,0,1], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [1,3,-2], color: [1,0,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-2,8,-2], color: [0,0,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [9,6,-5], color: [1,0.5,0], scene: self)
        
        
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [7,1,-4], color: [1,0,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [5,2,0], color: [0,1,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-1,6,9], color: [1,0,1], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [1,2.8,-7.4], color: [1,1,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-1,2,8], color: [0,1,1], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-5,2,-9], color: [1,0,1], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [4,6,2], color: [1,0,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-2,2,-2], color: [0,0,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-2,1,-8], color: [1,0.5,0], scene: self)
        
        
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-4,4,7.5], color: [1,0,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [5,1,0], color: [0,1,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-1,4,7], color: [1,0,1], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [1,2,-7], color: [1,1,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [4,5,-8], color: [0,1,1], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-5,2,1], color: [1,0,1], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [9,3,-2], color: [1,0,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [-2,3,-2], color: [0,0,0], scene: self)
        _ = GameAreaLight(vertex: ball_vertices, index: ball_indices, pos: [3,5,-8], color: [1,0.5,0], scene: self)*/

        
    }
    
    
    
    
        
}