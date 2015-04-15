//
//  MusicPlayerViewController.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 4/15/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

import UIKit

class MusicPlayerViewController: UIViewController {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timer: UISlider!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var endTime: UILabel!
    
    var songSource:SongModel = SongModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.songTitle.text = songSource.Title+" - "+songSource.Artist
        
        
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.width/2
        self.avatarImage.clipsToBounds = true
        let duration = 2.0
        let delay = 0.0
        let options = UIViewAnimationOptions.CurveLinear | .Repeat
        
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
                self.avatarImage.transform = CGAffineTransformRotate(self.avatarImage.transform,CGFloat(M_PI * 2.0))
            }, completion: nil)
        
        
        let block: SDWebImageCompletionBlock! = {(image: UIImage!, error: NSError!, cacheType: SDImageCacheType!, imageURL: NSURL!) -> Void in
        }
        let url = NSURL(string:songSource.ArtistAvatar)!
        self.avatarImage.sd_setImageWithURL(url, completed: block)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
