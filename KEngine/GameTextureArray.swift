//
//  KKHTextureArray.swift
//  KKHGame
//
//  Created by YiLi on 15/6/20.
//  Copyright © 2015年 YiLi. All rights reserved.
//

import Foundation
import Metal
import MetalKit




class GameTextureArray: NSObject {
    var m_count:Int = 0
    var m_scene:GameScene! = nil
    var m_texture2DArray:MTLTexture! = nil
    
    
    init(textureFilePaths:[String],scene:GameScene) {
        super.init()
        m_count = textureFilePaths.count
        m_scene = scene
        var textures = [MTLTexture]()
        for ele in textureFilePaths{
            let url = NSBundle.mainBundle().URLForResource(ele, withExtension: "png")
            do{
                let texture = try m_scene.m_utility.m_textureLoader.newTextureWithContentsOfURL(url!, options: nil)
                textures.append(texture)
            }catch let error as NSError{
                fatalError("texture error:\(error.localizedDescription)")
            }
        }
        let textureDesc = MTLTextureDescriptor()
        textureDesc.arrayLength = m_count
        textureDesc.textureType = MTLTextureType.Type2DArray
        textureDesc.pixelFormat = MTLPixelFormat.BGRA8Unorm
        textureDesc.width = 256
        textureDesc.height = 256
        m_texture2DArray = m_scene.m_device.newTextureWithDescriptor(textureDesc)
        
        var i: Int = 0
        for ele in textures{
            let buffer = UnsafeMutablePointer<Void>.alloc(256 * 256 * 4 * 4)
            ele.getBytes(buffer, bytesPerRow: 256 * 4, fromRegion: MTLRegionMake2D(0, 0, 256, 256), mipmapLevel: 0)
            
            m_texture2DArray.replaceRegion(MTLRegionMake2D(0, 0, 256, 256), mipmapLevel: 0, slice: i, withBytes: buffer, bytesPerRow: 256 * 4, bytesPerImage: 256 * 4 * 4 * 256)
            ++i
        }
        
    }
}