//
//  Descriptor.swift
//  KEngine
//
//  Created by 哈哈 on 15/8/27.
//  Copyright © 2015年 哈哈. All rights reserved.
//

import Foundation
import Metal




class Descriptor:NSObject {
    
    
    
    var m_renderPipelineDesc = MTLRenderPipelineDescriptor()
    var m_renderPassDesc = MTLRenderPassDescriptor()
    var m_depthDesc = MTLDepthStencilDescriptor()
    var m_stencilDesc = MTLStencilDescriptor()
    var m_deptAttachmentDesc = MTLRenderPassDepthAttachmentDescriptor()
    var m_stencilAttachmentDesc = MTLRenderPassStencilAttachmentDescriptor()
    var m_textureDesc = MTLTextureDescriptor()


    
    
    override init(){
        super.init()
    }
}