//
//  ViewController.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 3/31/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

import UIKit
let parseURL = "https://api.parse.com/1/classes/homepage"
let parseAppID = "Wd0mLuzvmUh8NJDnbHk5bAHsDsy21htt2jAOBGQP"
let parseRestKey = "S1Ut3LQSwzUvHbXIo06aY7PF0tN7tz81OsbEV2GH"

class HomeController: UIViewController , UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var myObjectArray = NSMutableArray()
    
    class HomeObject: NSObject {
        var text:NSString = ""
        var image:NSString = ""
        var order:Int = -1
        
        init(myText:NSString,myImage:NSString,myOrder:Int){
            self.text = myText
            self.image = myImage
            self.order = myOrder
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Set background color is white
        self.view.backgroundColor = UIColor.whiteColor()
        // Call API
        callParseAPI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func callParseAPI(){
        let manager = AFHTTPRequestOperationManager()
        manager.requestSerializer.setValue(parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        manager.requestSerializer.setValue(parseRestKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        manager.GET( parseURL,
            parameters: nil,
            success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                
                var myTempArray:NSMutableArray = NSMutableArray()
                myTempArray = responseObject["results"] as NSMutableArray
                for index in 0...myTempArray.count-1 {
                    var tempObj:NSDictionary = myTempArray[index] as NSDictionary
                    var homeObject:HomeObject = HomeObject(myText: tempObj["text"] as NSString, myImage: tempObj["image"] as NSString, myOrder: tempObj["order"] as Int)
                    self.myObjectArray.addObject(homeObject)
                    
                }
                self.tableView.reloadData()
            },
            failure: {
                (operation: AFHTTPRequestOperation!,error: NSError!) in println("Error:" + error.localizedDescription)
            }
        )
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : homepageCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as homepageCell
        var tempHomeObj:HomeObject = myObjectArray[indexPath.row] as HomeObject
        cell.labelHome.text = "AAA"
        println(tempHomeObj.text)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myObjectArray.count
    }
    
    

    
        
}

