//
//  MusicPlayerView+Animation.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 4/21/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

extension MusicPlayerViewController {
    // MARK: - Rotation
    
    func moveDisktoVinyl(){
        self.diskView.transform = CGAffineTransformMakeScale(1.05, 1.05)
        let duration = 2.0
        let delay = 0.0
        let options = UIViewAnimationOptions.CurveLinear
        UIView.animateWithDuration(duration, delay: delay, options: nil, animations: {
            self.diskView.frame.origin.x = self.view.frame.size.width * 0.9
            
            }, completion:{
                (value:Bool) in
                UIView.animateWithDuration(0.5, delay: 0.2, options:.CurveEaseInOut, animations: {
                    self.pochette.frame = CGRectMake(self.pochette.frame.origin.x - 500, self.pochette.frame.origin.y, self.pochette.frame.size.width, self.pochette.frame.size.height)
                    }, completion: {
                        (value:Bool) in
                        self.pochette.removeFromSuperview()
                })
                self.diskView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.rotateDisk()
                self.rotateKim()
                
        })
        
    }
    func rotateKim(){
        let duration = 1.0
        let delay = 0.0
        let options = UIViewAnimationOptions.CurveLinear
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
            self.kimVinyl.transform = CGAffineTransformRotate(self.kimVinyl.transform,CGFloat(M_PI)/4)
            }, completion:{
                (value:Bool)in
                self.playSong()
        })
    }
    func backKim(){
        self.pauseSong()
        let duration = 1.0
        let delay = 0.0
        let options = UIViewAnimationOptions.CurveLinear
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
            self.kimVinyl.transform = CGAffineTransformRotate(self.kimVinyl.transform,-CGFloat(M_PI)/4)
            }, completion:{
                (value:Bool)in
                
        })
        
    }
    func rotateDisk(){
        let duration = 2.0
        let delay = 0.0
        let options = UIViewAnimationOptions.CurveLinear | .AllowUserInteraction
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
            self.diskView.transform = CGAffineTransformRotate(self.diskView.transform,CGFloat(M_PI))
            }, completion:{
                (value:Bool) in
                self.rotateDisk()
        })
    }
    
}