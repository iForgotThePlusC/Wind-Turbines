//
//  TurbineNode.swift
//  WindTurbines
//
//  Created by Yicheng Xia on 12/11/2022.
//

import SpriteKit

class TurbineNode: SKSpriteNode {
    
    init(radius: CGFloat) {
        super.init(texture: SKTexture(imageNamed: "circle.png"), color: UIColor.blue, size: CGSize(width: radius * 2, height: radius * 2))
        
        colorBlendFactor = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
