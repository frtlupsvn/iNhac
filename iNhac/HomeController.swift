//
//  ViewController.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 3/31/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

//Trang home sẽ load bảng xếp hạng nhạc của: VIỆTNAM, ÂU MỸ, HÀNQUỐC

import UIKit

let parseURL = "https://api.parse.com/1/classes/homepage"

let zingURL = "http://api.mp3.zing.vn/api/list-chart"

let parseAppID = "Wd0mLuzvmUh8NJDnbHk5bAHsDsy21htt2jAOBGQP"
let parseRestKey = "S1Ut3LQSwzUvHbXIo06aY7PF0tN7tz81OsbEV2GH"

class HomeController: UIViewController , UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var imageSource = NSMutableArray()
    var dataSource = NSMutableArray()
    
    class ListChartObject: NSObject {
        var ID:NSString = ""
        var Name:NSString = ""
        var Type:NSString = ""
        
        init(myID:NSString,myName:NSString,myType:NSString){
            self.ID = myID
            self.Name = myName
            self.Type = myType
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Set background color is white
        self.view.backgroundColor = UIColor.whiteColor()
        imageSource.addObject("1.jpg")
        imageSource.addObject("3.jpg")
        imageSource.addObject("2.jpg")
        
        
        //Connect to Zing API
        callZingAPI()
    }
    
    func callZingAPI(){
        var publicKey:NSString = "4c3d549977f7943bd9cc6d33f656bb5c1c87d2c0"
        var privateKey:NSString = "c9c2a7f66b677012b763512da77040b3"
        
        //jsondata
        
        var jsonarray:NSMutableDictionary = NSMutableDictionary(object: "song", forKey: "t")
//        println("json: "+jsonarray.JSONString() as NSString)
        var jsondata:NSString = (jsonarray.JSONString() as NSString).base64EncodedString()
        jsondata = jsondata.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!

        var signature:NSString = (jsondata as NSString).HMAC_MD5_WithSecretString(privateKey)
        
//        println("signature: "+signature)
//        println("jsonData: "+jsondata)
        
//        var urlAPI = zingURL+"?publicKey="+publicKey+"&signature="+signature+"&jsondata="+jsondata
//        
//        println(urlAPI)
        
        var params = [
            "publicKey" : publicKey,
            "signature" : signature,
            "jsondata"  : jsondata,
        ]
        
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html")

        manager.GET( zingURL,
            parameters: params,
            success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                var resultArray:NSArray = responseObject as NSArray
                
                for index in 0...resultArray.count-1{
                    var temp: NSDictionary = resultArray.objectAtIndex(index) as NSDictionary
                    var chartObject:ListChartObject = ListChartObject(myID: (temp.objectForKey("ID"))as NSString, myName: (temp.objectForKey("Name"))as NSString, myType: (temp.objectForKey("Type"))as NSString)
                    self.dataSource.addObject(chartObject)
                    
                }
                    self.tableView.reloadData()
                    println("Succes")
            },
            failure: {
                (operation: AFHTTPRequestOperation!,error: NSError!) in println("Error:" + error.localizedDescription)
            }
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : homepageCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as homepageCell
        var chartObject:ListChartObject = dataSource.objectAtIndex(indexPath.row) as ListChartObject
        
        cell.labelHome.text = chartObject.Name
        cell.imageHome.image = UIImage(named: imageSource.objectAtIndex(indexPath.row) as NSString)
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.layer.borderWidth = 1
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    

    
        
}

