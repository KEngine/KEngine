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
    var m_cameraDelegate:CameraDelegate! = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        m_mtkView = self.view as! MTKView
        m_mtkView.device = m_device
        /*let size = UIScreen.mainScreen().bounds
        let scale = UIScreen.mainScreen().scale
        
        
        //iphone 6 plus downsample its resolution
        //let iphone6P = CGFloat(1.15)
        //m_mtkView.drawableSize = CGSize(width: CGFloat(size.width * scale / iphone6P), height: CGFloat(size.height * scale / iphone6P))*/
        setupViewPixelFormat()
        
        
        
        // render utility actor init
        m_utility = GameUtility(scene: self)
        m_render = GameDefferedRender(scene: self)
        m_mtkView.delegate = m_render
        m_cameraDelegate = m_utility.m_camera
        m_mtkView.preferredFramesPerSecond = 60
        addAppNotification()
        
        
        
        loadActor()
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

        let actor1 = GameActor(vertices: ball_vertices, indices: ball_indices, scene: self)
        actor1.translate(0, y: 0, z: 0)
        
        let actor2 = GameActor(vertices: sephere_vertices, indices: sephere_indices, scene: self)
        actor2.translate(0, y: 0, z: 3)
        
        let actor3 = GameActor(vertices: sephere_vertices, indices: sephere_indices, scene: self)
        actor3.translate(3, y: 1, z: -4)
        
        let actor4 = GameActor(vertices: sephere_vertices, indices: sephere_indices, scene: self)
        actor4.translate(-5, y: 0, z: -5)
        
        
        let actor5 = GameActor(vertices: plat_vertices, indices: plat_indices, scene: self)
        actor5.translate(0, y: 8, z: 0)
        
    }
    
    
    
    
        
}