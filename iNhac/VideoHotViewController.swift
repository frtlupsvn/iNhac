//
//  VideoHotViewController.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 4/9/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

import UIKit

class VideoHotViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : VideoTableViewCell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath) as VideoTableViewCell
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    


}
