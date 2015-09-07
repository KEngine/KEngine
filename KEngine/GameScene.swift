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



class GameScene: UIViewController{
    var m_device:MTLDevice = MTLCreateSystemDefaultDevice()!
    var m_mtkView:MTKView! = nil
    var m_utility:GameUtility! = nil
    var m_renderDelegate:MTKViewDelegate! = nil
    var m_render:GameDefferedRender! = nil
    var m_actor:[GameActor]! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        m_mtkView = self.view as! MTKView
        m_mtkView.device = m_device
        let size = UIScreen.mainScreen().bounds
        let scale = UIScreen.mainScreen().scale
        
        
        //iphone 6 plus downsample its resolution
        let iphone6P = CGFloat(1.15)
        m_mtkView.drawableSize = CGSize(width: CGFloat(size.width * scale / iphone6P), height: CGFloat(size.height * scale / iphone6P))
        setupViewPixelFormat()

        
        // render utility actor init
        m_utility = GameUtility(scene: self)
        m_render = GameDefferedRender(scene: self)
        m_mtkView.delegate = m_render
        m_mtkView.preferredFramesPerSecond = 60
        addAppNotification()
        
        
        
        loadActor()
        
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
        m_mtkView.depthStencilPixelFormat = MTLPixelFormat.Depth32Float_Stencil8
    }
    
    
    func loadActor(){
        m_actor = [GameActor]()

        let actor1 = GameActor(vertices: sephere_vertices, indices: sephere_indices, scene: self)
        actor1.translate(1, y: 0, z: 1)
        
        let actor2 = GameActor(vertices: sephere_vertices, indices: sephere_indices, scene: self)
        actor2.translate(-1, y: 1, z: 1)
        
        let actor3 = GameActor(vertices: sephere_vertices, indices: sephere_indices, scene: self)
        actor3.translate(3, y: 1, z: 3)
        
        let actor4 = GameActor(vertices: sephere_vertices, indices: sephere_indices, scene: self)
        actor4.translate(3, y: 0, z: 3)
        
        
        _ = GameActor(vertices: plat_vertices, indices: plat_indices, scene: self)
        
    }
    
    
    
    
        
}