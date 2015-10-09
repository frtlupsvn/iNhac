//
//  PlayerView.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 4/7/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

import UIKit

class PlayerView: UIView {
    
     override init(frame: CGRect) {
        super.init(frame: frame)
        let bundle = NSBundle(forClass: self.dynamicType)
        let view = bundle.loadNibNamed("PlayerView", owner: nil, options: nil)[0] as! PlayerView
        view.frame = self.bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(view)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
