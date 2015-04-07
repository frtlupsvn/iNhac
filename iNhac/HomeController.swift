//
//  ViewController.swift
//  iNhac
//
//  Created by Zoom NGUYEN on 3/31/15.
//  Copyright (c) 2015 ZoomStudio. All rights reserved.
//

//Trang home sẽ load bảng xếp hạng nhạc của: VIỆTNAM, ÂU MỸ, HÀNQUỐC

import UIKit

let LIST_CHART_API:NSString   = "http://api.mp3.zing.vn/api/list-chart"
let DETAIL_CHART_API:NSString = "http://api.mp3.zing.vn/api/chart-detail"

let publicKey:NSString = "4c3d549977f7943bd9cc6d33f656bb5c1c87d2c0"
let privateKey:NSString = "c9c2a7f66b677012b763512da77040b3"

class HomeController: UIViewController , UITableViewDataSource, UITableViewDelegate, FeSpinnerTenDotDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var imageSource = NSMutableArray()
    var dataSource = NSMutableArray()
    var arrTitleLoading = NSArray()
    var index = NSInteger()
    var spinner = FeSpinnerTenDot()
    
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
        
        // Set background color
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.topItem?.title = "BẢNG XẾP HẠNG"
        self.navigationController?.navigationBarHidden = true
        
        imageSource.addObject("1.jpg")
        imageSource.addObject("3.jpg")
        imageSource.addObject("2.jpg")
        
        //**************************************
        index = 0
        self.arrTitleLoading = ["LOADING","PlZ WAITTING","SUCCESSFUL"]
        // init Loader
        
        self.spinner = FeSpinnerTenDot(view: self.view, withBlur: true)
        self.spinner.backgroundColor = UIColor(hexCode: "#019875")
        self.spinner.titleLabelText = self.arrTitleLoading[self.index] as NSString
        self.spinner.fontTitleLabel = UIFont(name: "Neou-Thin", size: 36)
        self.view.addSubview(spinner)

        self.spinner.delegate = self
        
        //**************************************
        

        //Connect to Zing API
        getChartList()
    }
    
    func getChartList(){
        
        self.spinner.show()
    
        //jsondata
        
        var jsonarray:NSMutableDictionary = NSMutableDictionary(object: "song", forKey: "t")
        var jsondata:NSString = (jsonarray.JSONString() as NSString).base64EncodedString()
        jsondata = jsondata.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!

        var signature:NSString = (jsondata as NSString).HMAC_MD5_WithSecretString(privateKey)
        
        var params = [
            "publicKey" : publicKey,
            "signature" : signature,
            "jsondata"  : jsondata,
        ]
        
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html")
        
        //**************************************
        // CALL API
        
        manager.GET( LIST_CHART_API,
            parameters: params,
            success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                var resultArray:NSArray = responseObject as NSArray
                
                for index in 0...resultArray.count-1{
                    var temp: NSDictionary = resultArray.objectAtIndex(index) as NSDictionary
                    
                    var chartObject:ListChartObject = ListChartObject(myID: (temp.objectForKey("ID"))as NSString, myName: (temp.objectForKey("Name"))as NSString, myType: (temp.objectForKey("Type"))as NSString)
                    self.dataSource.addObject(chartObject)
                    
                }
                    var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("getDetailChartList"), userInfo: nil, repeats: false)

            },
            failure: {
                (operation: AFHTTPRequestOperation!,error: NSError!) in println("Error:" + error.localizedDescription)
            }
        )
        //**************************************
    }
    
    func getDetailChartList(){
        
        self.index++
        self.spinner.titleLabelText = self.arrTitleLoading[self.index] as NSString
        
        //jsondata
        
        var tempChartListObject:ListChartObject = self.dataSource[0] as ListChartObject
        
        var jsonarray:NSMutableDictionary = NSMutableDictionary(object: "IWZ9Z080", forKey: "id")
        
        var jsondata:NSString = (jsonarray.JSONString() as NSString).base64EncodedString()
        jsondata = jsondata.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!
        var signature:NSString = (jsondata as NSString).HMAC_MD5_WithSecretString(privateKey)
        
        println((jsonarray.JSONString() as NSString))
        println(jsondata)
        println(signature)
        
        var params = [
            "publicKey" : publicKey,
            "signature" : signature,
            "jsondata"  : jsondata,
        ]
        
        //**************************************
        // CALL API
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "text/html")
        
        manager.GET( DETAIL_CHART_API,
            parameters: params,
            success: {
                (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) in
                println("Thanh Cong")
                var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("chartDetailSuccess"), userInfo: nil, repeats: false)
            },
            failure: {
                (operation: AFHTTPRequestOperation!,error: NSError!) in println("Error:" + error.localizedDescription)
            }
        )
        
        //**************************************
        var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("chartDetailSuccess"), userInfo: nil, repeats: false)

    }
    
    func chartDetailSuccess(){
        self.tableView.reloadData()
        self.index++
        self.spinner.titleLabelText = self.arrTitleLoading[self.index] as NSString
        var timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("backToView"), userInfo: nil, repeats: false)

    }
    
    func backToView(){
        self.spinner.dismiss()
        self.navigationController?.navigationBarHidden = false
        
        var playerTabbar = PlayerView(frame: CGRectMake(0, self.view.frame.height-150, self.view.frame.width, 150))
        playerTabbar.layer.zPosition = 1
        UIApplication.sharedApplication().keyWindow?.addSubview(playerTabbar)
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

